//
//  ViewController.swift
//  MoscowEvents
//
//  Created by Diana Princess on 02.08.2022.
//

import UIKit
import Network

class EventCollectionViewController: UICollectionViewController, EventCollectionViewProtocol {
    var presenter: EventCollectionPresenterProtocol?
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    var topActivity = UIActivityIndicatorView(style: .medium)
    var bottomActivity = UIActivityIndicatorView(style: .large)
    override func viewDidLoad() {
        super.viewDidLoad()
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
        title = "События в Москве"
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(repeatRequest(_:)))
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(increaseCollection(_:)))
        swipeUp.direction = .up
        swipeDown.direction = .down
        swipeUp.numberOfTouchesRequired = 1
        swipeDown.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeDown)
        view.addGestureRecognizer(swipeUp)
        self.collectionView.register(EventCollectionViewCell.self, forCellWithReuseIdentifier: EventCollectionViewCell.reuseId)
        self.collectionView.backgroundColor = .white
        self.collectionView.contentInsetAdjustmentBehavior = .always
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        let collectionTopConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let collectionBottomConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        let collectionLeadingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let collectionTrailingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([collectionTopConstraint, collectionBottomConstraint, collectionLeadingConstraint, collectionTrailingConstraint])
        self.collectionView.dataSource = self.presenter
        self.collectionView.delegate = self.presenter
        self.collectionView.isUserInteractionEnabled = true
        self.collectionView.addGestureRecognizer(swipeUp)
        self.collectionView.addGestureRecognizer(swipeDown)
        // Do any additional setup after loading the view.
    }
    
    func reload(){
        DispatchQueue.main.async {
            self.collectionView.reloadData()
            if self.topActivity.isAnimating {
                self.topActivity.stopAnimating()
            }
            if self.bottomActivity.isAnimating {
                self.bottomActivity.stopAnimating()
            }
        }
    }
    func requestFailure(error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "При выполнении запроса произошла ошибка", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    func noInternet(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Отсутствует соединение с интернетом", message: "Пожалуйста, проверьте подключение и повторите попытку.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func increaseCollection(_ sender: UISwipeGestureRecognizer){
        DispatchQueue.main.async {
            self.view.addSubview(self.bottomActivity)
            self.bottomActivity.translatesAutoresizingMaskIntoConstraints = false
            let bottomActCenter = NSLayoutConstraint(item: self.bottomActivity, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
            let bottomActBottom = NSLayoutConstraint(item: self.bottomActivity, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -4)
            NSLayoutConstraint.activate([bottomActCenter, bottomActBottom])
            self.bottomActivity.startAnimating()
        }
        self.presenter?.additionalRequest()
    }
    @objc func repeatRequest(_ sender: UISwipeGestureRecognizer){
        DispatchQueue.main.async {
            self.view.addSubview(self.topActivity)
            self.topActivity.translatesAutoresizingMaskIntoConstraints = false
            let topActCenter = NSLayoutConstraint(item: self.topActivity, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1, constant: 0)
            let topActTop = NSLayoutConstraint(item: self.topActivity, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 4)
            NSLayoutConstraint.activate([topActCenter, topActTop])
            self.topActivity.startAnimating()
        }
        presenter?.repeatRequest()
    }
    
    func countCellWidth()->CGFloat{
        let cellWidth = (view.frame.width-30)/2
        return cellWidth ?? 150
    }
}

