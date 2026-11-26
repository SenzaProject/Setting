package androidx.preference;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.RecyclerView;
public abstract class PreferenceFragmentCompat extends Fragment {
    public PreferenceScreen getPreferenceScreen() { return null; }
    public RecyclerView getListView() { return null; }
}
