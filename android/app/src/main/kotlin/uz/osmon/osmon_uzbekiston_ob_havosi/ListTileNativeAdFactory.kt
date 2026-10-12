package uz.osmon.osmon_uzbekiston_ob_havosi

import android.view.LayoutInflater
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.RatingBar
import android.widget.TextView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.NativeAdView
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin

/**
 * Inflates the app-styled card layout (res/layout/native_ad_card.xml) for
 * Native Advanced ads. Registered under AdConfig.nativeAdFactoryId
 * ("listTile") in MainActivity so Dart's NativeAd(factoryId: ...) resolves
 * to this view.
 */
class ListTileNativeAdFactory(private val inflater: LayoutInflater) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?,
    ): NativeAdView {
        val adView = inflater.inflate(
            R.layout.native_ad_card,
            null,
        ) as NativeAdView

        val headlineView = adView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = adView.findViewById<TextView>(R.id.ad_body)
        val iconView = adView.findViewById<ImageView>(R.id.ad_icon)
        val ctaView = adView.findViewById<Button>(R.id.ad_cta)
        val starsView = adView.findViewById<RatingBar>(R.id.ad_stars)
        val badgeView = adView.findViewById<TextView>(R.id.ad_badge)

        // AdMob requires a visible, localized attribution badge.
        (customOptions?.get("adLabel") as? String)?.let { badgeView.text = it }

        headlineView.text = nativeAd.headline
        adView.headlineView = headlineView

        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = View.VISIBLE
        } else {
            bodyView.visibility = View.GONE
        }
        adView.bodyView = bodyView

        val icon = nativeAd.icon
        if (icon != null) {
            iconView.setImageDrawable(icon.drawable)
            iconView.visibility = View.VISIBLE
        } else {
            iconView.visibility = View.GONE
        }
        adView.iconView = iconView

        if (nativeAd.callToAction != null) {
            ctaView.text = nativeAd.callToAction
            ctaView.visibility = View.VISIBLE
        } else {
            ctaView.visibility = View.GONE
        }
        adView.callToActionView = ctaView

        val rating = nativeAd.starRating
        if (rating != null) {
            starsView.rating = rating.toFloat()
            starsView.visibility = View.VISIBLE
        } else {
            starsView.visibility = View.GONE
        }
        adView.starRatingView = starsView

        adView.setNativeAd(nativeAd)
        return adView
    }
}
