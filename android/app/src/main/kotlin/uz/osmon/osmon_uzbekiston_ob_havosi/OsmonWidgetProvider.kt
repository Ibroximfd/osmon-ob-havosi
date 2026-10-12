package uz.osmon.osmon_uzbekiston_ob_havosi

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget. Data is written from Dart by HomeWidgetSync
 * (lib/app/services/home_widget_sync.dart) — keep the keys in sync.
 * Tapping the widget opens the app.
 */
class OsmonWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.osmon_widget).apply {
                setTextViewText(R.id.widget_city, widgetData.getString("osmon_city", "Osmon"))
                setTextViewText(R.id.widget_temp, widgetData.getString("osmon_temp", "—"))
                setTextViewText(R.id.widget_condition, widgetData.getString("osmon_condition", ""))
                setTextViewText(R.id.widget_range, widgetData.getString("osmon_range", ""))
                setTextViewText(R.id.widget_outlook, widgetData.getString("osmon_outlook", ""))
                setTextViewText(R.id.widget_updated, widgetData.getString("osmon_updated", ""))
                val background = if (widgetData.getString("osmon_scene", "day") == "night") {
                    R.drawable.widget_background_night
                } else {
                    R.drawable.widget_background_day
                }
                setInt(R.id.widget_root, "setBackgroundResource", background)
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
