.class public Lcom/android/settings/system/SystemDashboardFragment;
.super Lcom/android/settings/dashboard/DashboardFragment;
.source "SourceFile"


# static fields
.field public static final SEARCH_INDEX_DATA_PROVIDER:Li4/a;

.field public static final d:[Ljava/lang/String;

.field public static final e:[Ljava/lang/String;

.field public static final f:[Ljava/lang/String;

.field public static final g:[Ljava/lang/String;

.field public static final h:[Ljava/lang/String;

.field public static final i:[Ljava/lang/String;


# instance fields
.field public b:Lcom/transsion/settings/system/UserManualCategoryController;

.field public c:Z


# direct methods
.method static constructor <clinit>()V
    .registers 22

    const-string v9, "MN"

    const-string v10, "GE"

    const-string v0, "ID"

    const-string v1, "EG"

    const-string v2, "TR"

    const-string v3, "EU"

    const-string v4, "KG"

    const-string v5, "AZ"

    const-string v6, "UZ"

    const-string v7, "TJ"

    const-string v8, "TM"

    filled-new-array/range {v0 .. v10}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/android/settings/system/SystemDashboardFragment;->d:[Ljava/lang/String;

    const-string v0, "TR"

    const-string v1, "SA"

    const-string v2, "ID"

    const-string v3, "EG"

    filled-new-array {v2, v3, v0, v1}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/android/settings/system/SystemDashboardFragment;->e:[Ljava/lang/String;

    const-string v13, "SA"

    const-string v14, "QA"

    const-string v1, "EG"

    const-string v2, "EU"

    const-string v3, "RS"

    const-string v4, "RU"

    const-string v5, "ID"

    const-string v6, "TR"

    const-string v7, "BY"

    const-string v8, "KZ"

    const-string v9, "UA"

    const-string v10, "DZ"

    const-string v11, "KW"

    const-string v12, "AE"

    filled-new-array/range {v1 .. v14}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/android/settings/system/SystemDashboardFragment;->f:[Ljava/lang/String;

    const-string v20, "UY"

    const-string v21, "GY"

    const-string v1, "CO"

    const-string v2, "AR"

    const-string v3, "PY"

    const-string v4, "PA"

    const-string v5, "BR"

    const-string v6, "EC"

    const-string v7, "CR"

    const-string v8, "HT"

    const-string v9, "PE"

    const-string v10, "MX"

    const-string v11, "VE"

    const-string v12, "BO"

    const-string v13, "CL"

    const-string v14, "JM"

    const-string v15, "HN"

    const-string v16, "GT"

    const-string v17, "SV"

    const-string v18, "NI"

    const-string v19, "DO"

    filled-new-array/range {v1 .. v21}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/android/settings/system/SystemDashboardFragment;->g:[Ljava/lang/String;

    const-string v9, "X6851"

    const-string v10, "X6852"

    const-string v1, "X6856"

    const-string v2, "X6870"

    const-string v3, "X6873"

    const-string v4, "X6876"

    const-string v5, "X6855"

    const-string v6, "X6857"

    const-string v7, "X6858"

    const-string v8, "X6896"

    filled-new-array/range {v1 .. v10}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/android/settings/system/SystemDashboardFragment;->h:[Ljava/lang/String;

    const-string v0, "X6725"

    const-string v1, "X6873"

    const-string v2, "X6711"

    const-string v3, "X6852"

    const-string v4, "X6857"

    filled-new-array {v2, v3, v4, v0, v1}, [Ljava/lang/String;

    move-result-object v0

    sput-object v0, Lcom/android/settings/system/SystemDashboardFragment;->i:[Ljava/lang/String;

    new-instance v0, Lcom/android/settings/system/g;

    const/4 v1, 0x1

    invoke-direct {v0, v1}, Lcom/android/settings/system/g;-><init>(I)V

    sput-object v0, Lcom/android/settings/system/SystemDashboardFragment;->SEARCH_INDEX_DATA_PROVIDER:Li4/a;

    return-void
.end method

.method public constructor <init>()V
    .registers 2

    invoke-direct {p0}, Lcom/android/settings/dashboard/DashboardFragment;-><init>()V

    const/4 v0, 0x1

    iput-boolean v0, p0, Lcom/android/settings/system/SystemDashboardFragment;->c:Z

    return-void
.end method

.method public static y0(Landroid/content/Context;)Z
    .registers 5

    sget-boolean v0, LN5/f;->d:Z

    const/4 v1, 0x0

    if-eqz v0, :cond_6

    goto :goto_26

    :cond_6
    sget-object v0, Landroid/os/Build;->MODEL:Ljava/lang/String;

    if-eqz v0, :cond_27

    sget-object v2, Lcom/android/settings/system/SystemDashboardFragment;->h:[Ljava/lang/String;

    invoke-static {}, Lcom/transsion/settings/deviceinfo/aboutphone/CertifiedInfoActivity;->d()Ljava/lang/String;

    move-result-object v3

    invoke-virtual {v3}, Ljava/lang/String;->toUpperCase()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Lcom/android/internal/util/ArrayUtils;->contains([Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_27

    invoke-static {}, LN5/f;->f()Ljava/lang/String;

    move-result-object v2

    const-string v3, "TH"

    invoke-virtual {v3, v2}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v2

    if-eqz v2, :cond_27

    :goto_26
    return v1

    :cond_27
    sget-object v2, Lcom/android/settings/system/SystemDashboardFragment;->g:[Ljava/lang/String;

    invoke-static {}, LN5/f;->f()Ljava/lang/String;

    move-result-object v3

    invoke-static {v2, v3}, Lcom/android/internal/util/ArrayUtils;->contains([Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v2

    const/4 v3, 0x1

    if-eqz v2, :cond_54

    if-eqz v0, :cond_53

    sget-object v0, Lcom/android/settings/system/SystemDashboardFragment;->i:[Ljava/lang/String;

    invoke-static {}, Lcom/transsion/settings/deviceinfo/aboutphone/CertifiedInfoActivity;->d()Ljava/lang/String;

    move-result-object v2

    invoke-virtual {v2}, Ljava/lang/String;->toUpperCase()Ljava/lang/String;

    move-result-object v2

    invoke-static {v0, v2}, Lcom/android/internal/util/ArrayUtils;->contains([Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_53

    invoke-static {}, LN5/f;->f()Ljava/lang/String;

    move-result-object v0

    const-string v2, "BR"

    invoke-virtual {v2, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_53

    goto :goto_54

    :cond_53
    move v3, v1

    :cond_54
    :goto_54
    const-string v0, "com.transsion.manualguide"

    invoke-static {p0, v0}, LN5/f;->r(Landroid/content/Context;Ljava/lang/String;)Z

    move-result v0

    if-nez v0, :cond_5d

    move v3, v1

    :cond_5d
    invoke-static {p0}, LN5/f;->u(Landroid/content/Context;)Z

    move-result p0

    const-string v0, "SystemDashboardFrag"

    if-eqz p0, :cond_6b

    const-string p0, "is Demo4Stores mode "

    invoke-static {v0, p0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    move v3, v1

    :cond_6b
    invoke-static {}, LN5/n;->n()LN5/d;

    move-result-object p0

    invoke-virtual {p0}, LN5/d;->C()Z

    move-result p0

    if-eqz p0, :cond_87

    sget-object p0, Lcom/android/settings/system/SystemDashboardFragment;->d:[Ljava/lang/String;

    invoke-static {}, LN5/f;->f()Ljava/lang/String;

    move-result-object v2

    invoke-static {p0, v2}, Lcom/android/internal/util/ArrayUtils;->contains([Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_87

    const-string p0, "BLOCK_MANUAL_COUNTRY_CODES_INFINIX"

    invoke-static {v0, p0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    move v3, v1

    :cond_87
    invoke-static {}, LN5/n;->n()LN5/d;

    move-result-object p0

    invoke-virtual {p0}, LN5/d;->s()Z

    move-result p0

    if-eqz p0, :cond_a3

    sget-object p0, Lcom/android/settings/system/SystemDashboardFragment;->e:[Ljava/lang/String;

    invoke-static {}, LN5/f;->f()Ljava/lang/String;

    move-result-object v2

    invoke-static {p0, v2}, Lcom/android/internal/util/ArrayUtils;->contains([Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_a3

    const-string p0, "BLOCK_MANUAL_COUNTRY_CODES_TECNO"

    invoke-static {v0, p0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    move v3, v1

    :cond_a3
    invoke-static {}, LN5/n;->n()LN5/d;

    move-result-object p0

    invoke-virtual {p0}, LN5/d;->t()Z

    move-result p0

    if-eqz p0, :cond_bf

    sget-object p0, Lcom/android/settings/system/SystemDashboardFragment;->f:[Ljava/lang/String;

    invoke-static {}, LN5/f;->f()Ljava/lang/String;

    move-result-object v2

    invoke-static {p0, v2}, Lcom/android/internal/util/ArrayUtils;->contains([Ljava/lang/Object;Ljava/lang/Object;)Z

    move-result p0

    if-eqz p0, :cond_bf

    const-string p0, "BLOCK_MANUAL_COUNTRY_CODES_ITEL"

    invoke-static {v0, p0}, Landroid/util/Log;->d(Ljava/lang/String;Ljava/lang/String;)I

    return v1

    :cond_bf
    return v3
.end method


# virtual methods
.method public final createPreferenceControllers(Landroid/content/Context;)Ljava/util/List;
    .registers 5

    new-instance p1, Ljava/util/ArrayList;

    invoke-direct {p1}, Ljava/util/ArrayList;-><init>()V

    new-instance v0, Lcom/transsion/settings/system/UserManualCategoryController;

    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object v1

    const-string v2, "manual_guide_category"

    invoke-direct {v0, v1, v2}, Lcom/transsion/settings/system/UserManualCategoryController;-><init>(Landroid/content/Context;Ljava/lang/String;)V

    iput-object v0, p0, Lcom/android/settings/system/SystemDashboardFragment;->b:Lcom/transsion/settings/system/UserManualCategoryController;

    invoke-virtual {p1, v0}, Ljava/util/ArrayList;->add(Ljava/lang/Object;)Z

    return-object p1
.end method

.method public final dynamicBindPreference(Landroidx/preference/PreferenceScreen;Landroidx/preference/Preference;Lcom/android/settingslib/drawer/Tile;)Z
    .registers 6

    const/4 p1, 0x0

    if-nez p2, :cond_4

    return p1

    :cond_4
    if-eqz p3, :cond_18

    invoke-virtual {p3}, Lcom/android/settingslib/drawer/Tile;->f()Ljava/lang/String;

    move-result-object v0

    const-string v1, "com.idea.questionnaire/com.transsion.xfeedback.ui.MyFeedbackActivity"

    invoke-virtual {v1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-eqz v0, :cond_18

    const v0, 0x7f0e0491

    invoke-virtual {p2, v0}, Landroidx/preference/Preference;->setLayoutResource(I)V

    :cond_18
    if-eqz p3, :cond_39

    const-string v0, "com.transsion.systemupdate/com.transsion.systemupdate.SystemUpdateActivity"

    invoke-virtual {p3}, Lcom/android/settingslib/drawer/Tile;->f()Ljava/lang/String;

    move-result-object p3

    invoke-virtual {v0, p3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p3

    if-eqz p3, :cond_39

    invoke-virtual {p0}, Lcom/android/settings/SettingsPreferenceFragment;->getContentResolver()Landroid/content/ContentResolver;

    move-result-object p3

    const-string v0, "ota_new_version"

    invoke-static {p3, v0, p1}, Landroid/provider/Settings$Global;->getInt(Landroid/content/ContentResolver;Ljava/lang/String;I)I

    move-result p3

    const/4 v0, 0x1

    if-ne p3, v0, :cond_39

    const p3, 0x7f0e051c

    invoke-virtual {p2, p3}, Landroidx/preference/Preference;->setLayoutResource(I)V

    :cond_39
    invoke-virtual {p2}, Landroidx/preference/Preference;->getKey()Ljava/lang/String;

    move-result-object p3

    iget-object p0, p0, Lcom/android/settings/system/SystemDashboardFragment;->b:Lcom/transsion/settings/system/UserManualCategoryController;

    invoke-virtual {p0}, Lcom/android/settings/core/c;->isAvailable()Z

    move-result p0

    const-string v0, "dashboard_tile_pref_com.transsion.manualguide.MainActivity"

    invoke-virtual {v0, p3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result v0

    if-nez v0, :cond_53

    const-string v0, "dashboard_tile_pref_com.transsion.itel.manual.MainActivity"

    invoke-virtual {v0, p3}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z

    move-result p3

    if-eqz p3, :cond_58

    :cond_53
    if-nez p0, :cond_58

    invoke-virtual {p2, p1}, Landroidx/preference/Preference;->setVisible(Z)V

    :cond_58
    return p1
.end method

.method public final getLogTag()Ljava/lang/String;
    .registers 1

    const-string p0, "SystemDashboardFrag"

    return-object p0
.end method

.method public final getMetricsCategory()I
    .registers 1

    const/16 p0, 0x2e8

    return p0
.end method

.method public final getPreferenceScreenResId()I
    .registers 1

    const p0, 0x7f19014e

    return p0
.end method

.method public final onCreate(Landroid/os/Bundle;)V
    .registers 2

    invoke-super {p0, p1}, Lcom/android/settings/dashboard/DashboardFragment;->onCreate(Landroid/os/Bundle;)V

    invoke-virtual {p0}, Landroidx/fragment/app/Fragment;->getContext()Landroid/content/Context;

    move-result-object p0

    invoke-virtual {p0}, Landroid/content/Context;->getApplicationContext()Landroid/content/Context;

    move-result-object p0

    const/4 p1, 0x0

    invoke-static {p0, p1}, Lcom/transsion/kolun/oxygenbus/common/KolunOxygenBusRegister;->initClientAsync(Landroid/content/Context;Lcom/transsion/kolun/oxygenbus/common/KolunOxygenBusRegister$InitOxygenBusCallback;)V

    return-void
.end method

.method public final onDynamicTileInsertionFinished()V
    .registers 4

    iget-boolean v0, p0, Lcom/android/settings/system/SystemDashboardFragment;->c:Z

    if-nez v0, :cond_5

    goto :goto_b

    :cond_5
    invoke-virtual {p0}, Landroidx/preference/PreferenceFragmentCompat;->getListView()Landroidx/recyclerview/widget/RecyclerView;

    move-result-object v0

    if-nez v0, :cond_c

    :goto_b
    return-void

    :cond_c
    new-instance v1, Lcom/android/settings/inputmethod/p;

    const/16 v2, 0xf

    invoke-direct {v1, v2, p0, v0}, Lcom/android/settings/inputmethod/p;-><init>(ILjava/lang/Object;Ljava/lang/Object;)V

    invoke-virtual {v0, v1}, Landroid/view/View;->post(Ljava/lang/Runnable;)Z

    return-void
.end method

.method public final onResume()V
    .registers 3

    invoke-super {p0}, Lcom/android/settings/dashboard/DashboardFragment;->onResume()V

    invoke-virtual {p0}, Landroidx/preference/PreferenceFragmentCompat;->getPreferenceScreen()Landroidx/preference/PreferenceScreen;

    invoke-virtual {p0}, Landroidx/preference/PreferenceFragmentCompat;->getListView()Landroidx/recyclerview/widget/RecyclerView;

    move-result-object v1

    if-eqz v1, :cond_10

    const/4 v0, 0x0

    invoke-virtual {v1, v0}, Landroid/view/View;->setVerticalScrollBarEnabled(Z)V

    :cond_10
    invoke-static {p0}, Lcom/senza/addons/SenzaAddons;->onResume(Ljava/lang/Object;)V

    return-void
.end method

.method public final onViewCreated(Landroid/view/View;Landroid/os/Bundle;)V
    .registers 3

    invoke-super {p0, p1, p2}, Lcom/android/settings/dashboard/DashboardFragment;->onViewCreated(Landroid/view/View;Landroid/os/Bundle;)V

    invoke-virtual {p0}, Landroidx/preference/PreferenceFragmentCompat;->getListView()Landroidx/recyclerview/widget/RecyclerView;

    move-result-object p1

    if-eqz p1, :cond_11

    new-instance p2, Lcom/android/settings/system/h;

    invoke-direct {p2, p0}, Lcom/android/settings/system/h;-><init>(Lcom/android/settings/system/SystemDashboardFragment;)V

    invoke-virtual {p1, p2}, Landroidx/recyclerview/widget/RecyclerView;->addOnScrollListener(Landroidx/recyclerview/widget/RecyclerView$OnScrollListener;)V

    :cond_11
    return-void
.end method

.method public onActivityResult(IILandroid/content/Intent;)V
    .registers 4

    invoke-super {p0, p1, p2, p3}, Lcom/android/settings/dashboard/DashboardFragment;->onActivityResult(IILandroid/content/Intent;)V

    invoke-static {p0, p1, p2, p3}, Lcom/senza/addons/SenzaAddons;->onActivityResult(Ljava/lang/Object;IILandroid/content/Intent;)V

    return-void
.end method
