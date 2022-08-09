//
//  EventCollectionViewCell.swift
//  MoscowEvents
//
//  Created by Diana Princess on 02.08.2022.
//

import UIKit

class EventCollectionViewCell: UICollectionViewCell {
    static let reuseId = "EventCell"
    private let titleLabel: UILabel = {
        let label =  UILabel()
        label.contentMode = .scaleAspectFit
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    private let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    private let fogView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return v
    }()
    override init(frame: CGRect) {
            super.init(frame: frame)
            setupSubviews()
    }
    required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }
    func setupSubviews(){
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let imageTopConstraint = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
        let imageBottomConstraint = NSLayoutConstraint(item: imageView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        let imageLeadingConstraint = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0)
        let imageTrailingConstraint = NSLayoutConstraint(item: imageView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([imageTopConstraint, imageBottomConstraint, imageLeadingConstraint, imageTrailingConstraint])
        contentView.addSubview(fogView)
        fogView.translatesAutoresizingMaskIntoConstraints = false
        let fogTopConstraint = NSLayoutConstraint(item: fogView, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 0)
        let fogBottomConstraint = NSLayoutConstraint(item: fogView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: 0)
        let fogLeadingConstraint = NSLayoutConstraint(item: fogView, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 0)
        let fogTrailingConstraint = NSLayoutConstraint(item: fogView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([fogTopConstraint, fogBottomConstraint, fogLeadingConstraint, fogTrailingConstraint])
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleTopConstraint = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: contentView, attribute: .top, multiplier: 1, constant: 10)
        let titleBottomConstraint = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1, constant: -10)
        let titleLeadingConstraint = NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: contentView, attribute: .leading, multiplier: 1, constant: 10)
        let titleTrailingConstraint = NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1, constant: -10)
        NSLayoutConstraint.activate([titleTopConstraint, titleBottomConstraint, titleLeadingConstraint, titleTrailingConstraint])
    }
    func configure(title: String, image: UIImage?){
        imageView.image = image
        titleLabel.attributedText = NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
    }
}
