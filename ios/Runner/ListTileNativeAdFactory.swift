import GoogleMobileAds
import UIKit
import google_mobile_ads

/// Builds the app-styled native ad card entirely in code (no Storyboard/XIB
/// needed). Registered under the same factoryId ("listTile") that Dart's
/// NativeAd(factoryId: ...) calls reference.
class ListTileNativeAdFactory: NSObject, FLTNativeAdFactory {
  func createNativeAd(
    _ nativeAd: GADNativeAd,
    customOptions: [AnyHashable: Any]? = nil
  ) -> GADNativeAdView? {
    let adView = GADNativeAdView()
    adView.backgroundColor = UIColor.white.withAlphaComponent(0.10)
    adView.layer.cornerRadius = 20
    adView.layer.borderWidth = 1
    adView.layer.borderColor = UIColor.white.withAlphaComponent(0.17).cgColor
    adView.clipsToBounds = true

    let iconView = UIImageView()
    iconView.contentMode = .scaleAspectFill
    iconView.clipsToBounds = true
    iconView.layer.cornerRadius = 10
    iconView.translatesAutoresizingMaskIntoConstraints = false

    let badgeLabel = UILabel()
    // AdMob requires a visible, localized attribution badge.
    badgeLabel.text = " \((customOptions?["adLabel"] as? String) ?? "Ad") "
    badgeLabel.font = .boldSystemFont(ofSize: 9)
    badgeLabel.textColor = UIColor(red: 0.02, green: 0.08, blue: 0.11, alpha: 1.0)
    badgeLabel.backgroundColor = UIColor(red: 0.94, green: 0.72, blue: 0.27, alpha: 1.0)
    badgeLabel.textAlignment = .center
    badgeLabel.layer.cornerRadius = 3
    badgeLabel.clipsToBounds = true
    badgeLabel.translatesAutoresizingMaskIntoConstraints = false

    let headlineLabel = UILabel()
    headlineLabel.font = .boldSystemFont(ofSize: 14)
    headlineLabel.textColor = .white
    headlineLabel.numberOfLines = 1
    headlineLabel.translatesAutoresizingMaskIntoConstraints = false

    let bodyLabel = UILabel()
    bodyLabel.font = .systemFont(ofSize: 12)
    bodyLabel.textColor = UIColor.white.withAlphaComponent(0.72)
    bodyLabel.numberOfLines = 2
    bodyLabel.translatesAutoresizingMaskIntoConstraints = false

    let ctaButton = UIButton(type: .system)
    ctaButton.titleLabel?.font = .boldSystemFont(ofSize: 12)
    ctaButton.setTitleColor(UIColor(red: 0.02, green: 0.08, blue: 0.11, alpha: 1.0), for: .normal)
    ctaButton.backgroundColor = UIColor(red: 0.23, green: 0.76, blue: 0.86, alpha: 1.0)
    ctaButton.layer.cornerRadius = 14
    ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
    ctaButton.isUserInteractionEnabled = false
    ctaButton.translatesAutoresizingMaskIntoConstraints = false

    let badgeHeadlineRow = UIStackView(arrangedSubviews: [badgeLabel, headlineLabel])
    badgeHeadlineRow.axis = .horizontal
    badgeHeadlineRow.spacing = 6
    badgeHeadlineRow.alignment = .center

    let textColumn = UIStackView(arrangedSubviews: [badgeHeadlineRow, bodyLabel])
    textColumn.axis = .vertical
    textColumn.spacing = 2

    let rootRow = UIStackView(arrangedSubviews: [iconView, textColumn, ctaButton])
    rootRow.axis = .horizontal
    rootRow.spacing = 10
    rootRow.alignment = .center
    rootRow.translatesAutoresizingMaskIntoConstraints = false

    adView.addSubview(rootRow)
    NSLayoutConstraint.activate([
      iconView.widthAnchor.constraint(equalToConstant: 44),
      iconView.heightAnchor.constraint(equalToConstant: 44),
      // At least 15pt each way, as the native ads policy requires.
      badgeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 16),
      badgeLabel.heightAnchor.constraint(equalToConstant: 16),

      rootRow.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 12),
      rootRow.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -12),
      rootRow.topAnchor.constraint(equalTo: adView.topAnchor, constant: 12),
      rootRow.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -12),
    ])

    headlineLabel.text = nativeAd.headline
    adView.headlineView = headlineLabel

    if let body = nativeAd.body {
      bodyLabel.text = body
      bodyLabel.isHidden = false
    } else {
      bodyLabel.isHidden = true
    }
    adView.bodyView = bodyLabel

    if let icon = nativeAd.icon {
      iconView.image = icon.image
      iconView.isHidden = false
    } else {
      iconView.isHidden = true
    }
    adView.iconView = iconView

    if let cta = nativeAd.callToAction {
      ctaButton.setTitle(cta, for: .normal)
      ctaButton.isHidden = false
    } else {
      ctaButton.isHidden = true
    }
    adView.callToActionView = ctaButton

    adView.nativeAd = nativeAd
    return adView
  }
}
