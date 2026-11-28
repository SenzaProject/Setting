package com.senza.addons;

import android.app.Activity;
import android.app.AlertDialog;
import android.app.Application;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.os.Bundle;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.util.Log;
import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RadioButton;
import android.widget.RadioGroup;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.Toast;

import androidx.preference.Preference;
import androidx.preference.PreferenceCategory;
import androidx.preference.PreferenceFragmentCompat;
import androidx.preference.PreferenceGroup;
import androidx.preference.PreferenceScreen;
import androidx.recyclerview.widget.RecyclerView;

import java.io.File;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

/**
 * Senza Addon's - dipanggil dari SystemDashboardFragment (halaman Sistem, TranSettings).
 * TANPA root: aplikasi tidak pernah memanggil su. Fitur yang butuh akses sysfs dikirim lewat
 * system property ke eksekutor kecil di ROM (senza_addons.rc + senza_apply.sh).
 * Semua operasi berisiko dibungkus try/catch Throwable supaya Settings tidak pernah crash.
 */
public final class SenzaAddons {
    private static final String TAG = "SenzaAddons";
    private static final String PREFS = "senza_addons";
    private static final String KEY_ENTRY = "senza_addons_entry";
    private static final String KEY_OTA =
            "dashboard_tile_pref_com.transsion.systemupdate.SystemUpdateActivity";
    private static final int REQ_BANNER = 0x5A01;
    private static final Handler UI = new Handler(Looper.getMainLooper());

    private SenzaAddons() { }

    // ------------------------------------------------------------------ hooks

    public static void onResume(Object o) {
        try {
            final PreferenceFragmentCompat f = (PreferenceFragmentCompat) o;
            inject(f);
            scheduleBanner(f);
            Context ctx = f.getContext();
            if (ctx != null) registerXos(ctx);
        } catch (Throwable t) {
            Log.e(TAG, "onResume", t);
        }
    }

    public static void onActivityResult(Object o, int req, int res, Intent data) {
        try {
            if (req != REQ_BANNER || res != -1 || data == null || data.getData() == null) return;
            final PreferenceFragmentCompat f = (PreferenceFragmentCompat) o;
            final Context c = f.getContext();
            final Uri u = data.getData();
            if (c == null) return;
            new Thread() {
                @Override public void run() {
                    try {
                        saveBanner(c, u);
                        toast(c, "Banner OTA disimpan. Buka ulang halaman Sistem / cek kartu OTA.");
                        UI.post(new Runnable() { @Override public void run() { scheduleBanner(f); } });
                    } catch (Throwable t) {
                        Log.e(TAG, "saveBanner", t);
                        toast(c, "Gagal menyimpan banner");
                    }
                }
            }.start();
        } catch (Throwable t) {
            Log.e(TAG, "onActivityResult", t);
        }
    }

    // ------------------------------------------------------------ menu entry

    private static void inject(final PreferenceFragmentCompat f) {
        Context ctx = f.getContext();
        PreferenceScreen screen = f.getPreferenceScreen();
        if (ctx == null || screen == null) return;
        if (screen.findPreference(KEY_ENTRY) != null) return;

        PreferenceCategory cat = new PreferenceCategory(ctx);
        cat.setKey(KEY_ENTRY + "_cat");
        cat.setOrder(Integer.MAX_VALUE);
        screen.addPreference(cat);

        Preference p = new Preference(ctx);
        p.setKey(KEY_ENTRY);
        p.setTitle("Senza Addon's");
        p.setSummary("Performa, thermal, driver game, CPU & GPU, banner OTA");
        p.setPersistent(false);
        p.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {
            @Override public boolean onPreferenceClick(Preference preference) {
                try { openDialog(f); } catch (Throwable t) { Log.e(TAG, "openDialog", t); }
                return true;
            }
        });
        cat.addPreference(p);
    }

    // ------------------------------------------------------- utils (TANPA root)

    private static SharedPreferences sp(Context c) {
        return c.getSharedPreferences(PREFS, 0);
    }

    private static void toast(final Context c, final String m) {
        UI.post(new Runnable() {
            @Override public void run() { Toast.makeText(c, m, Toast.LENGTH_SHORT).show(); }
        });
    }

    private static String getProp(String k) {
        try {
            Class<?> cls = Class.forName("android.os.SystemProperties");
            String v = (String) cls.getMethod("get", String.class, String.class).invoke(null, k, "");
            return v == null ? "" : v;
        } catch (Throwable t) {
            return "";
        }
    }

    private static boolean setProp(String k, String v) {
        try {
            Class<?> cls = Class.forName("android.os.SystemProperties");
            cls.getMethod("set", String.class, String.class).invoke(null, k, v);
            return true;
        } catch (Throwable t) {
            Log.w(TAG, "setProp gagal: " + k, t);
            return false;
        }
    }

    /**
     * Kirim konfigurasi ke eksekutor di ROM (senza_addons.rc + senza_apply.sh) lewat system property.
     * Aplikasi TIDAK memanggil su. Format: t=0|1,g=auto|bal|perf,m=100|85|70|55|40,u=0|1|2,r=gl|vk
     */
    private static void pushCfg(final Context c, final String okMsg) {
        SharedPreferences s = sp(c);
        final String cfg = "t=" + s.getInt("t", 0)
                + ",g=" + s.getString("g", "auto")
                + ",m=" + s.getInt("m", 100)
                + ",u=" + s.getInt("u", 0)
                + ",r=" + s.getString("r", "gl")
                + ",n=" + ((System.currentTimeMillis() / 1000L) % 100000L);
        new Thread() {
            @Override public void run() {
                String before = getProp("sys.senza.status");
                boolean ok = setProp("persist.sys.senza.cfg", cfg);
                if (!ok) ok = setProp("sys.senza.cfg", cfg);
                if (!ok) {
                    toast(c, "Gagal mengirim pengaturan (properti ditolak SELinux). Lihat guide.");
                    return;
                }
                try { Thread.sleep(2500); } catch (InterruptedException ignore) { }
                String st = getProp("sys.senza.status");
                if (st.length() == 0 || st.equals(before)) {
                    toast(c, "Pengaturan terkirim, tapi eksekutor ROM belum merespons (cek senza_addons.rc)");
                } else {
                    toast(c, okMsg);
                }
            }
        }.start();
    }

    // ------------------------------------------------------------ dialog UI

    private static final int[] PCTS = {100, 85, 70, 55, 40};
    private static final String[] GOV_KEYS = {"auto", "bal", "perf"};
    private static final String[] GOV_LABELS = {"Otomatis (tidak diubah)", "Seimbang", "Performa"};

    private interface Pick { void pick(int index); }

    private static void openDialog(final PreferenceFragmentCompat f) {
        final Context c = f.getContext();
        if (c == null) return;
        buildDialog(f, c);
    }

    private static int dp(Context c, int v) {
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v,
                c.getResources().getDisplayMetrics());
    }

    private static TextView title(Context c, String s) {
        TextView t = new TextView(c);
        t.setText(s);
        t.setTextSize(TypedValue.COMPLEX_UNIT_SP, 16);
        t.setTypeface(null, android.graphics.Typeface.BOLD);
        t.setPadding(0, dp(c, 18), 0, dp(c, 6));
        return t;
    }

    private static TextView note(Context c, String s) {
        TextView t = new TextView(c);
        t.setText(s);
        t.setTextSize(TypedValue.COMPLEX_UNIT_SP, 12);
        t.setAlpha(0.65f);
        return t;
    }

    private static RadioGroup radios(Context c, String[] labels, int checked, final Pick cb) {
        final RadioGroup g = new RadioGroup(c);
        g.setOrientation(RadioGroup.VERTICAL);
        for (int i = 0; i < labels.length; i++) {
            RadioButton b = new RadioButton(c);
            b.setId(View.generateViewId());
            b.setText(labels[i]);
            g.addView(b);
            if (i == checked) b.setChecked(true);
        }
        g.setOnCheckedChangeListener(new RadioGroup.OnCheckedChangeListener() {
            @Override public void onCheckedChanged(RadioGroup grp, int id) {
                int idx = grp.indexOfChild(grp.findViewById(id));
                if (idx >= 0) cb.pick(idx);
            }
        });
        return g;
    }

    private static int idxOf(String[] a, String v) {
        for (int i = 0; i < a.length; i++) if (a[i].equals(v)) return i;
        return 0;
    }

    private static void buildDialog(final PreferenceFragmentCompat f, final Context c) {
        final SharedPreferences prefs = sp(c);
        final AlertDialog[] dlg = new AlertDialog[1];
        LinearLayout box = new LinearLayout(c);
        box.setOrientation(LinearLayout.VERTICAL);
        box.setPadding(dp(c, 22), dp(c, 6), dp(c, 22), dp(c, 12));

        String st = getProp("sys.senza.status");
        TextView stat = note(c, st.length() == 0
                ? "Eksekutor ROM: belum aktif. Thermal, CPU, GPU, dan mode performa butuh "
                  + "senza_addons.rc terpasang di ROM (lihat guide). Tap rotation, driver ANGLE "
                  + "dan banner tetap jalan."
                : "Eksekutor ROM: aktif (" + st + ")");
        stat.setAlpha(1f);
        box.addView(stat);

        // --- Umum
        box.addView(title(c, "Umum"));
        final Switch swRot = new Switch(c);
        swRot.setText("Nonaktifkan tap rotation (tombol saran putar)");
        boolean rotOff = false;
        try {
            rotOff = Settings.Secure.getInt(c.getContentResolver(), "show_rotation_suggestions", 1) == 0;
        } catch (Throwable ignore) { }
        swRot.setChecked(rotOff);
        swRot.setOnCheckedChangeListener(new android.widget.CompoundButton.OnCheckedChangeListener() {
            @Override public void onCheckedChanged(android.widget.CompoundButton b, boolean on) {
                boolean ok = false;
                try {
                    ok = Settings.Secure.putInt(c.getContentResolver(), "show_rotation_suggestions", on ? 0 : 1);
                } catch (Throwable ignore) { }
                toast(c, ok ? (on ? "Tap rotation dinonaktifkan" : "Tap rotation diaktifkan")
                        : "Gagal mengubah pengaturan");
            }
        });
        box.addView(swRot);

        final Switch swTh = new Switch(c);
        swTh.setText("Nonaktifkan thermal throttling");
        swTh.setChecked(prefs.getInt("t", 0) == 1);
        swTh.setOnCheckedChangeListener(new android.widget.CompoundButton.OnCheckedChangeListener() {
            @Override public void onCheckedChanged(android.widget.CompoundButton b, boolean on) {
                prefs.edit().putInt("t", on ? 1 : 0).apply();
                pushCfg(c, on ? "Thermal throttling dinonaktifkan" : "Thermal dikembalikan");
            }
        });
        box.addView(swTh);
        box.addView(note(c, "Hati-hati: suhu bisa naik tinggi saat beban berat."));

        // --- Mode performa
        box.addView(title(c, "Mode performa"));
        final String[] modes = {"Hemat daya", "Seimbang", "Performa"};
        box.addView(radios(c, modes, prefs.getInt("mode", -1), new Pick() {
            @Override public void pick(int i) {
                SharedPreferences.Editor e = prefs.edit();
                e.putInt("mode", i);
                e.putString("g", i == 2 ? "perf" : "bal");
                e.putInt("m", i == 0 ? 55 : 100);
                e.putInt("u", i == 0 ? 2 : (i == 2 ? 1 : 0));
                e.apply();
                pushCfg(c, "Mode " + modes[i] + " diterapkan");
                if (dlg[0] != null) dlg[0].dismiss();
                UI.post(new Runnable() {
                    @Override public void run() { buildDialog(f, c); }
                });
            }
        }));
        box.addView(note(c, "Mengatur governor + batas frekuensi CPU dan batas GPU sekaligus."));

        // --- Driver grafis
        box.addView(title(c, "Driver grafis game"));
        String[] drv = {"OpenGL (default)", "Vulkan", "ANGLE"};
        box.addView(radios(c, drv, prefs.getInt("driver", -1), new Pick() {
            @Override public void pick(int i) {
                prefs.edit().putInt("driver", i).putString("r", i == 1 ? "vk" : "gl").apply();
                try {
                    Settings.Global.putInt(c.getContentResolver(), "angle_gl_driver_all_angle", i == 2 ? 1 : 0);
                } catch (Throwable t) {
                    Log.w(TAG, "angle setting", t);
                }
                pushCfg(c, "Driver diterapkan. Tutup paksa lalu buka lagi game/aplikasi.");
            }
        }));
        box.addView(note(c, "ANGLE diatur langsung lewat pengaturan sistem. Vulkan (renderer UI) lewat eksekutor ROM. "
                + "Berlaku untuk proses yang dijalankan setelahnya."));

        // --- CPU
        box.addView(title(c, "CPU"));
        final Spinner sg = new Spinner(c);
        sg.setAdapter(new ArrayAdapter<String>(c, android.R.layout.simple_spinner_dropdown_item, GOV_LABELS));
        final int[] gSel = {idxOf(GOV_KEYS, prefs.getString("g", "auto"))};
        sg.setSelection(gSel[0]);

        String[] pl = new String[PCTS.length];
        for (int i = 0; i < PCTS.length; i++) pl[i] = "maks " + PCTS[i] + "%";
        final Spinner sm = new Spinner(c);
        sm.setAdapter(new ArrayAdapter<String>(c, android.R.layout.simple_spinner_dropdown_item, pl));
        int curM = prefs.getInt("m", 100);
        int mi = 0;
        for (int i = 0; i < PCTS.length; i++) if (PCTS[i] == curM) mi = i;
        final int[] mSel = {mi};
        sm.setSelection(mi);

        LinearLayout row = new LinearLayout(c);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.addView(sg, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
        row.addView(sm, new LinearLayout.LayoutParams(0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));
        box.addView(row);

        sg.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override public void onItemSelected(AdapterView<?> parent, View v, int pos, long id) {
                if (pos == gSel[0]) return;
                gSel[0] = pos;
                prefs.edit().putString("g", GOV_KEYS[pos]).apply();
                pushCfg(c, "Governor CPU: " + GOV_LABELS[pos]);
            }
            @Override public void onNothingSelected(AdapterView<?> parent) { }
        });
        sm.setOnItemSelectedListener(new AdapterView.OnItemSelectedListener() {
            @Override public void onItemSelected(AdapterView<?> parent, View v, int pos, long id) {
                if (pos == mSel[0]) return;
                mSel[0] = pos;
                prefs.edit().putInt("m", PCTS[pos]).apply();
                pushCfg(c, "Batas frekuensi CPU: " + PCTS[pos] + "%");
            }
            @Override public void onNothingSelected(AdapterView<?> parent) { }
        });
        box.addView(note(c, "Berlaku ke semua cluster CPU. Governor dipilih otomatis sesuai yang tersedia di kernel."));

        // --- GPU
        box.addView(title(c, "GPU"));
        String[] gp = {"Otomatis", "Performa (kunci frekuensi tertinggi)", "Hemat (batasi frekuensi)"};
        box.addView(radios(c, gp, prefs.getInt("u", 0), new Pick() {
            @Override public void pick(int i) {
                prefs.edit().putInt("u", i).apply();
                pushCfg(c, "GPU: " + (i == 0 ? "otomatis" : (i == 1 ? "performa" : "hemat")));
            }
        }));
        box.addView(note(c, "Memakai node MediaTek gpufreq / ged. Kalau tidak ada di kernel, diabaikan."));

        // --- Banner OTA
        box.addView(title(c, "Banner Card"));
        Button pick = new Button(c);
        pick.setText("Pilih dari galeri");
        pick.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                try {
                    Intent i = new Intent(Intent.ACTION_GET_CONTENT);
                    i.setType("image/*");
                    i.addCategory(Intent.CATEGORY_OPENABLE);
                    f.startActivityForResult(i, REQ_BANNER);
                } catch (Throwable t) {
                    toast(c, "Tidak bisa membuka galeri");
                }
            }
        });
        Button reset = new Button(c);
        reset.setText("Kembalikan banner asli");
        reset.setOnClickListener(new View.OnClickListener() {
            @Override public void onClick(View v) {
                String path = prefs.getString("banner", null);
                if (path != null) new File(path).delete();
                prefs.edit().remove("banner").apply();
                toast(c, "Banner asli dikembalikan setelah halaman dibuka ulang");
            }
        });
        LinearLayout.LayoutParams lp1 = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp1.topMargin = dp(c, 8);
        LinearLayout.LayoutParams lp2 = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp2.topMargin = dp(c, 14);
        lp2.bottomMargin = dp(c, 10);
        box.addView(pick, lp1);
        box.addView(reset, lp2);
        box.addView(note(c, "By Senza Project"));

        ScrollView sv = new ScrollView(c);
        sv.addView(box);
        dlg[0] = new AlertDialog.Builder(c).setTitle("Senza Addon's").setView(sv)
                .setPositiveButton(android.R.string.ok, null).create();
        dlg[0].show();
    }

    // --------------------------------------------------------------- banner

    private static void saveBanner(Context c, Uri u) throws Exception {
        InputStream in = c.getContentResolver().openInputStream(u);
        BitmapFactory.Options o = new BitmapFactory.Options();
        o.inJustDecodeBounds = true;
        BitmapFactory.decodeStream(in, null, o);
        in.close();
        int s = 1;
        while (o.outWidth / (s * 2) >= 1280) s *= 2;
        o.inJustDecodeBounds = false;
        o.inSampleSize = s;
        in = c.getContentResolver().openInputStream(u);
        Bitmap b = BitmapFactory.decodeStream(in, null, o);
        in.close();
        if (b == null) throw new Exception("decode gagal");
        File out = new File(c.getFilesDir(), "senza_ota_banner.jpg");
        FileOutputStream fo = new FileOutputStream(out);
        b.compress(Bitmap.CompressFormat.JPEG, 92, fo);
        fo.close();
        sp(c).edit().putString("banner", out.getAbsolutePath()).apply();
    }

    private static void scheduleBanner(final PreferenceFragmentCompat f) {
        RecyclerView rv = f.getListView();
        if (rv == null) return;
        Runnable r = new Runnable() {
            @Override public void run() {
                try { applyBanner(f); } catch (Throwable t) { Log.e(TAG, "applyBanner", t); }
            }
        };
        rv.postDelayed(r, 400);
        rv.postDelayed(r, 1200);
    }

    private static void applyBanner(PreferenceFragmentCompat f) {
        Context c = f.getContext();
        if (c == null) return;
        String path = sp(c).getString("banner", null);
        if (path == null || !new File(path).exists()) return;
        RecyclerView rv = f.getListView();
        if (rv == null) return;
        Object ad = rv.getAdapter();
        if (!(ad instanceof PreferenceGroup.PreferencePositionCallback)) return;
        int pos = ((PreferenceGroup.PreferencePositionCallback) ad).getPreferenceAdapterPosition(KEY_OTA);
        if (pos < 0) return;
        for (int i = 0; i < rv.getChildCount(); i++) {
            View child = rv.getChildAt(i);
            if (rv.getChildAdapterPosition(child) != pos) continue;
            List<ImageView> imgs = new ArrayList<ImageView>();
            collect(child, imgs);
            ImageView best = null;
            long area = 0;
            for (ImageView iv : imgs) {
                long a = (long) iv.getWidth() * iv.getHeight();
                if (iv.getWidth() >= child.getWidth() / 3 && a > area) { area = a; best = iv; }
            }
            if (best == null) {
                Log.w(TAG, "ImageView banner tidak ditemukan di kartu OTA");
                return;
            }
            Bitmap bmp = BitmapFactory.decodeFile(path);
            if (bmp == null) return;
            best.setImageTintList(null);
            best.setScaleType(ImageView.ScaleType.CENTER_CROP);
            best.setImageBitmap(bmp);
            return;
        }
    }


    // ------------------------------------------------- banner kartu XOS (Ponsel saya)

    /** Cadangan id view latar kartu XOS; utamanya dicari lewat nama "os_version_bg" (aman lintas ROM). */
    private static final int ID_XOS_BG = 0x7f0b0861;
    private static boolean cbRegistered = false;

    private static void registerXos(Context c) {
        if (cbRegistered) return;
        Context app = c.getApplicationContext();
        if (!(app instanceof Application)) return;
        cbRegistered = true;
        ((Application) app).registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
            @Override public void onActivityResumed(final Activity a) {
                try {
                    final Runnable r = new Runnable() {
                        @Override public void run() {
                            try { applyXos(a); } catch (Throwable t) { Log.e(TAG, "applyXos", t); }
                        }
                    };
                    View d = a.getWindow().getDecorView();
                    d.postDelayed(r, 300);
                    d.postDelayed(r, 1200);
                } catch (Throwable t) {
                    Log.e(TAG, "onActivityResumed", t);
                }
            }
            @Override public void onActivityCreated(Activity a, Bundle b) { }
            @Override public void onActivityStarted(Activity a) { }
            @Override public void onActivityPaused(Activity a) { }
            @Override public void onActivityStopped(Activity a) { }
            @Override public void onActivitySaveInstanceState(Activity a, Bundle b) { }
            @Override public void onActivityDestroyed(Activity a) { }
        });
    }

    private static void applyXos(Activity a) {
        String path = sp(a).getString("banner", null);
        if (path == null || !new File(path).exists()) return;
        int id = a.getResources().getIdentifier("os_version_bg", "id", a.getPackageName());
        if (id == 0) id = ID_XOS_BG;
        View v = a.getWindow().getDecorView().findViewById(id);
        if (v == null) return;
        Bitmap bmp = BitmapFactory.decodeFile(path);
        if (bmp == null) return;
        if (v instanceof ImageView) {
            ImageView iv = (ImageView) v;
            iv.setImageTintList(null);
            iv.setScaleType(ImageView.ScaleType.CENTER_CROP);
            iv.setImageBitmap(bmp);
        } else {
            v.setBackground(new BitmapDrawable(a.getResources(), bmp));
        }
    }

    private static void collect(View v, List<ImageView> out) {
        if (v instanceof ImageView) {
            out.add((ImageView) v);
        } else if (v instanceof ViewGroup) {
            ViewGroup g = (ViewGroup) v;
            for (int i = 0; i < g.getChildCount(); i++) collect(g.getChildAt(i), out);
        }
    }
}
