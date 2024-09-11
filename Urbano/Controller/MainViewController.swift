//
//  MainViewController.swift
//  Urbano
//
//  Created by Mick VE on 6/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var boxImageView: UIView!
    @IBOutlet weak var imgBGHome: UIImageView!
    @IBOutlet weak var photoUserImage: UIImageView!
    @IBOutlet weak var boxSearchBar: UIView!
    //var searchResultsController = UISearchController()
    
    var currentIndexBGHome = 1
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPhotoUser()
        
        addShadowWithRoundedCorners(view: boxImageView)
        addCorners(view: imgBGHome)
        addCorners(view: boxSearchBar)
        
        let boxSearchBarDidTap = UITapGestureRecognizer(target: self, action: #selector(self.boxSearchBarDidTap(_:)))
        boxSearchBar.addGestureRecognizer(boxSearchBarDidTap)
        
        let photoUserDidTap = UITapGestureRecognizer(target: self, action: #selector(self.photoUserDidTap))
        photoUserImage.addGestureRecognizer(photoUserDidTap)
        
        //searchBar.delegate = self
        //searchBar.setValue("Cancelar", forKey: "_cancelButtonText")
        /*
         let storyboard = UIStoryboard(name: "GuiaSearch", bundle: nil)
         let guiaSearchTableVC = storyboard.instantiateInitialViewController() as! GuiaSearchTableViewController
         
         searchResultsController = UISearchController(searchResultsController: guiaSearchTableVC)
         searchResultsController.searchResultsUpdater = guiaSearchTableVC
         //searchResultsController.delegate = self
         let searchBar = searchResultsController.searchBar
         searchBar.sizeToFit()
         searchBar.placeholder = "Search for places"
         navigationItem.titleView = searchResultsController.searchBar
         searchResultsController.hidesNavigationBarDuringPresentation = false
         searchResultsController.dimsBackgroundDuringPresentation = true
         definesPresentationContext = true
         */
        
        /* resultSearchController = UISearchController(searchResultsController: locationSearchTable)
         resultSearchController?.searchResultsUpdater = locationSearchTable
         let searchBar = resultSearchController!.searchBar
         searchBar.sizeToFit()
         searchBar.placeholder = "Search for places"
         navigationItem.titleView = resultSearchController?.searchBar
         resultSearchController?.hidesNavigationBarDuringPresentation = false
         resultSearchController?.dimsBackgroundDuringPresentation = true*/
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidLogInNotificationHandler),
                                               name: Constant.NotificationName.UserDidLogIn, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidLogOutNotificationHandler),
                                               name: Constant.NotificationName.UserDidLogOut, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.runTimerAnimateBGHome()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("Call shouldPerformSegue")
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Call prepare")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // function which is triggered when handleTap is called
    @objc func boxSearchBarDidTap(_ sender: UITapGestureRecognizer) {
        let sb = UIStoryboard(name: "BuscarGuia", bundle: nil)
        self.present(sb.instantiateInitialViewController()!, animated: true, completion: nil)
    }
    
    @objc func photoUserDidTap() {
        if !UserSession.isUserLogged() {
            Helper.showLoginView(viewController: self)
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
        return cell
    }
    
    func addShadowWithRoundedCorners(view: UIView) {
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 1, height: 15)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 15
        //view.layer.masksToBounds = true
    }
    
    func addCorners(view: UIView) {
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        // border
        //        boxEstadoGuia.layer.borderWidth = 1.0
        //        boxEstadoGuia.layer.borderColor = UIColor.black.cgColor
    }
    
    func setupPhotoUser() {
        if UserSession.isUserLogged() {
            let url = URL(string: UserDefaultsManager.shared.userSessionPhotoURL!)
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url!)
                DispatchQueue.main.async {
                    if let _ = data {
                        self.photoUserImage.image = UIImage(data: data!)
                        self.photoUserImage.layer.cornerRadius = self.photoUserImage.frame.width / 2
                        self.photoUserImage.clipsToBounds = true
                    } else {
                        self.photoUserImage.image = UIImage(named: "ic_user_male_40pt")
                    }
                }
            }
        } else {
            self.photoUserImage.image = UIImage(named: "ic_user_male_40pt")
        }
    }
    
    func runTimerAnimateBGHome() {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: (#selector(animateBGHome)), userInfo: nil, repeats: true)
    }
    
    @objc func animateBGHome() {
        self.currentIndexBGHome += 1
        UIView.transition(with: self.imgBGHome, duration: 1.0, options: [.transitionCrossDissolve], animations: {
            self.imgBGHome.image = UIImage(named: "bg_home_\(self.currentIndexBGHome)")
        }, completion: { (success:Bool) in
            if self.currentIndexBGHome == 4 {
                self.currentIndexBGHome = 0
            }
        })
    }

}

extension MainViewController: NotificationHandlerDelegate {
    
    func userDidLogInNotificationHandler(notification: Notification) {
        // guard let userSessionProfile = notification.object as? UserSession.Profile else { return }
        setupPhotoUser()
    }
    
    func userDidLogOutNotificationHandler(notification: Notification) {
        setupPhotoUser()
    }
    
}
