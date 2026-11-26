package androidx.preference;
import android.content.Context;
public class Preference {
    public interface OnPreferenceClickListener { boolean onPreferenceClick(Preference preference); }
    public Preference(Context c) { }
    public void setKey(String k) { }
    public String getKey() { return null; }
    public void setTitle(CharSequence t) { }
    public void setSummary(CharSequence s) { }
    public void setOrder(int o) { }
    public void setPersistent(boolean p) { }
    public void setOnPreferenceClickListener(OnPreferenceClickListener l) { }
}
