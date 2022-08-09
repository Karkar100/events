//
//  EventViewController.swift
//  MoscowEvents
//
//  Created by Diana Princess on 03.08.2022.
//

import UIKit
import Network

class EventScreenViewController: UIViewController, EventScreenViewProtocol {

    private let titleLabel : UILabel = {
     let lbl = UILabel()
     lbl.textColor = .black
     lbl.textAlignment = .left
        
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
     return lbl
    }()
    private let detailedLabel : UILabel = {
     let lbl = UILabel()
     lbl.textColor = .black
     lbl.textAlignment = .left
    lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
     return lbl
    }()
    private let dateLabel : UILabel = {
     let lbl = UILabel()
     lbl.textColor = .black
     lbl.textAlignment = .left
    lbl.numberOfLines = 0
    lbl.lineBreakMode = .byWordWrapping
     return lbl
     }()
    private let scrollView = UIScrollView()
    var imgView: UIImageView?
    var imageArray: [UIImageView] = []
    var presenter: EventScreenPresenterProtocol?
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        monitor.pathUpdateHandler = { pathUpdateHandler in
                    if pathUpdateHandler.status == .satisfied {
                        print("Internet connection is on.")
                    } else {
                        DispatchQueue.main.async {
                            Task{
                                await self.noInternet()
                            }
                        }
                    }
                }
        monitor.start(queue: queue)
        configureViews()
        setupConstraints()
        // Do any additional setup after loading the view.
    }
    
    func configureViews(){
        view.addSubview(titleLabel)
        view.addSubview(detailedLabel)
        view.addSubview(dateLabel)
        
    }
    func setupConstraints(){
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        let titleTop = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 85)
        let titleLeading = NSLayoutConstraint(item: titleLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 37)
        let titleTrailing = NSLayoutConstraint(item: titleLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -37)
        let titleH  = view.frame.height*0.15
        let titleHeight = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: titleH)
        NSLayoutConstraint.activate([titleTop, titleLeading, titleTrailing, titleHeight])
        detailedLabel.translatesAutoresizingMaskIntoConstraints = false
        let detailTop = NSLayoutConstraint(item: detailedLabel, attribute: .top, relatedBy: .equal, toItem: titleLabel, attribute: .bottom, multiplier: 1, constant: 5)
        let detailLeading = NSLayoutConstraint(item: detailedLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 37)
        let detailTrailing = NSLayoutConstraint(item: detailedLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -37)
        let detailH = view.frame.height*0.28
        let detailHeight = NSLayoutConstraint(item: detailedLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: detailH)
        NSLayoutConstraint.activate([detailTop, detailLeading, detailTrailing, detailHeight])
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        let dateTop = NSLayoutConstraint(item: dateLabel, attribute: .top, relatedBy: .equal, toItem: detailedLabel, attribute: .bottom, multiplier: 1, constant: 5)
        let dateLeading = NSLayoutConstraint(item: dateLabel, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 37)
        let dateTrailing = NSLayoutConstraint(item: dateLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -37)
        let dateH = view.frame.height*0.07
        let dateHeight = NSLayoutConstraint(item: dateLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: dateH)
        NSLayoutConstraint.activate([dateTop, dateLeading, dateTrailing, dateHeight])
        
    }

    func requestFailure(error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "При выполнении запроса произошла ошибка", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func fillData(title: String, description: String, dateStart: Int, dateEnd: Int){
        DispatchQueue.main.async {
            self.titleLabel.attributedText = NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 30, weight: .medium)])
            self.detailedLabel.attributedText = NSAttributedString(string: description, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14)])
            let dateOfStart = Date(timeIntervalSince1970: TimeInterval(dateStart))
            let dateOfEnd = Date(timeIntervalSince1970: TimeInterval(dateEnd))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.YYYY, HH:mm"
            let dateString = "Дата и время проведения: "+dateFormatter.string(from: dateOfStart)+" - "+dateFormatter.string(from: dateOfEnd)
            self.dateLabel.attributedText = NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 16)])
        }
    }
    func createImageView(image: UIImage){
        DispatchQueue.main.async {
            let iv = UIImageView()
            iv.image = image
            iv.contentMode = .center
            self.imageArray.append(iv)
        }
    }
    func displayImages(){
        if imageArray.count > 2 {
            imageScroll()
        } else {
            onlyImages()
        }
    }
    
    func onlyImages(){
        DispatchQueue.main.async {
            for i in 0...self.imageArray.count-1{
                if i == 0{
                    self.imgView = self.imageArray[0]
                    self.view.addSubview(self.imgView!)
                    self.imgView?.translatesAutoresizingMaskIntoConstraints = false
                    let imageTop = NSLayoutConstraint(item: self.imgView, attribute: .top, relatedBy: .equal, toItem: self.dateLabel, attribute: .bottom, multiplier: 1, constant: 5)
                    let imageLeading = NSLayoutConstraint(item: self.imgView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 37)
                    let imageWidth = NSLayoutConstraint(item: self.imgView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 150)
                    let imageH = (self.view.frame.height*0.35)-10
                    let imageHeight = NSLayoutConstraint(item: self.imgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: imageH)
                    NSLayoutConstraint.activate([imageTop, imageLeading, imageWidth, imageHeight])
                } else {
                    let imageView = self.imageArray[i]
                    self.view.addSubview(imageView)
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    let imageTop = NSLayoutConstraint(item: imageView, attribute: .top, relatedBy: .equal, toItem: self.dateLabel, attribute: .bottom, multiplier: 1, constant: 5)
                    let imageLeading = NSLayoutConstraint(item: imageView, attribute: .leading, relatedBy: .equal, toItem: self.imgView, attribute: .leading, multiplier: 1, constant: 37)
                    let imageWidth = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 150)
                    let imageH = (self.view.frame.height*0.35)-10
                    let imageHeight = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: imageH)
                    NSLayoutConstraint.activate([imageTop, imageLeading, imageWidth, imageHeight])
                }
            }
        }
    }
    func imageScroll(){
        DispatchQueue.main.async {
            self.view.addSubview(self.scrollView)
            self.scrollView.translatesAutoresizingMaskIntoConstraints = false
            let scrollTop = NSLayoutConstraint(item: self.scrollView, attribute: .top, relatedBy: .equal, toItem: self.dateLabel, attribute: .bottom, multiplier: 1, constant: 5)
            let scrollLeading = NSLayoutConstraint(item: self.scrollView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 37)
            let scrollTrailing = NSLayoutConstraint(item: self.scrollView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: -37)
            let scrollH = (self.view.frame.height*0.35)-10
            let scrollHeight = NSLayoutConstraint(item: self.scrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: scrollH)
            NSLayoutConstraint.activate([scrollTop, scrollHeight, scrollLeading, scrollTrailing])
            let stackView = UIStackView(arrangedSubviews: self.imageArray)
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 10
            self.scrollView.addSubview(stackView)
            stackView.translatesAutoresizingMaskIntoConstraints = false
            let stackTop = NSLayoutConstraint(item: stackView, attribute: .top, relatedBy: .equal, toItem: self.scrollView, attribute: .top, multiplier: 1, constant: 0)
            let stackBottom = NSLayoutConstraint(item: stackView, attribute: .bottom, relatedBy: .equal, toItem: self.scrollView, attribute: .bottom, multiplier: 1, constant: 0)
            let stackLeading = NSLayoutConstraint(item: stackView, attribute: .leading, relatedBy: .equal, toItem: self.scrollView, attribute: .leading, multiplier: 1, constant: 0)
            let stackTrailing = NSLayoutConstraint(item: stackView, attribute: .trailing, relatedBy: .equal, toItem: self.scrollView, attribute: .trailing, multiplier: 1, constant: 0)
            NSLayoutConstraint.activate([stackTop, stackBottom, stackLeading, stackTrailing])
        }
    }
    func noInternet() async {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Отсутствует соединение с интернетом", message: "Пожалуйста, проверьте подключение и перезапустите приложение.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
