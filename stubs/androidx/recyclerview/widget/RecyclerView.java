package androidx.recyclerview.widget;
import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
public class RecyclerView extends ViewGroup {
    public static abstract class Adapter { }
    public RecyclerView(Context c) { super(c); }
    @Override protected void onLayout(boolean changed, int l, int t, int r, int b) { }
    public Adapter getAdapter() { return null; }
    public int getChildAdapterPosition(View child) { return -1; }
}
