package androidx.preference;
import android.content.Context;
public class PreferenceGroup extends Preference {
    public interface PreferencePositionCallback {
        int getPreferenceAdapterPosition(String key);
        int getPreferenceAdapterPosition(Preference preference);
    }
    public PreferenceGroup(Context c) { super(c); }
    public boolean addPreference(Preference p) { return false; }
    public <T extends Preference> T findPreference(CharSequence key) { return null; }
}
