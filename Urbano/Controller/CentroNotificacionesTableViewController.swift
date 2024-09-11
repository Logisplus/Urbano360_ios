//
//  CentroNotificacionesTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 11/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class CentroNotificacionesTableViewController: UITableViewController {
    
    var notificaciones = [FetchCentroNotificacionesResponse.Notificacion]()
    
    let refreshCtrl = UIRefreshControl()
    
    var loadingView: LoadingViewController?
    
    var requireLoginNAV: DefaultNavigationController?
    var requireLoginVC: RequireLoginViewController?
    var requireLoginMainView: UIView?
    var requireLoginView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        refreshCtrl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.refreshControl = refreshCtrl
        tableView.register(UINib(nibName: "CentroNotificacionesTableViewCell", bundle: nil), forCellReuseIdentifier: "notificacionCell")
        
        setupNotificationHandlerDelegate()
        
        if UserSession.isUserLogged() {
            fetchNotificaciones(showLoadingView: true)
        } else {
            showRequireLoginView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notificaciones.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificacionCell", for: indexPath) as! CentroNotificacionesTableViewCell
        
        cell.setupNotificacion(notificacion: notificaciones[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "BuscarGuia", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RastrearEnvioStoryboard") as! RastrearEnvioViewController
        vc.searchGuia = notificaciones[indexPath.row].guia
        vc.hidesBottomBarWhenPushed = true
        show(vc, sender: nil)
    }
    
    func fetchNotificaciones(showLoadingView: Bool) {
        loadingView = nil
        if showLoadingView {
            loadingView = LoadingViewController(message: "Loading...")
            self.present(loadingView!, animated: true, completion: nil)
        }
        
        let params = FetchCentroNotificacionesRequest(idUsuario: UserSession.getUserSessionID())
        API.fetchCentroNotificaciones(params: params) { (data, error) in
            DispatchQueue.main.async {
                self.dismissLoadingViewOnRequest(loadingView: self.loadingView, refreshControl: self.refreshCtrl, completion: {
                    if let _ = error {
                        let alertController = UIAlertController(title: "Lo sentimos, ocurrió un error",
                                                                message: error,
                                                                preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
                        
                        alertController.addAction(action)
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    
                    if let data = data {
                        guard data.success else {
                            let alertController = UIAlertController(title: "Lo sentimos, ocurrió un error",
                                                                    message: "\(data.msg_error)",
                                preferredStyle: .alert)
                            
                            let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
                            
                            alertController.addAction(action)
                            self.present(alertController, animated: true, completion: nil)
                            return
                        }
                        
                        self.loadDataForTableView(notificaciones: data.data)
                    }
                })
            }
        }
    }
    
    func dismissLoadingViewOnRequest(loadingView: LoadingViewController? = nil, refreshControl: UIRefreshControl? = nil, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            if let _ = loadingView {
                loadingView!.dismiss(animated: true, completion: completion)
            } else {
                refreshControl!.endRefreshing()
                completion()
            }
        }
    }
    
    func loadDataForTableView(notificaciones: [FetchCentroNotificacionesResponse.Notificacion]) {
        self.notificaciones = notificaciones
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func setupNotificationHandlerDelegate() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidLogInNotificationHandler),
                                               name: Constant.NotificationName.UserDidLogIn,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidLogOutNotificationHandler),
                                               name: Constant.NotificationName.UserDidLogOut,
                                               object: nil)
    }
    
    /*func showRequireLoginView() {
        requireLoginView = RequireLoginView.instanceFromNib()
        requireLoginView!.delegate = self
        requireLoginView!.setupView(descripcion: "Regístrate con tu perfil de Facebook o Google para ver las notificaciones de tus envíos.",
                                    imagen: UIImage(named: "ic_package_hand_100pt")!)
        navigationController?.view.addSubview(requireLoginView!)
        print("Width: \(self.view.bounds.size.width)")
        print("Height: \(self.view.bounds.size.height)")
        print("Width: \(navigationController?.view.bounds.size.width)")
        print("Height: \(navigationController?.view.bounds.size.height)")
        print("Child Height: \(requireLoginView!.bounds.size.height)")
        
        requireLoginView!.frame = navigationController!.view.bounds
        
        
        
        /*requireLoginView!.frame = CGRect(x: 0,
                                         y: 64.0, // self.view.bounds.size.height - requireLoginView!.bounds.size.height,
            width: self.view.bounds.size.width,
            height: requireLoginView!.bounds.size.height - 64.0)*/
        
        requireLoginView!.frame = CGRect(x: 0,
                                         y: 0, // self.view.bounds.size.height - requireLoginView!.bounds.size.height,
            width: self.view.bounds.size.width,
            height: requireLoginView!.bounds.size.height)
    }*/
    
    func showRequireLoginView() {
        if requireLoginNAV == nil {
            let storyboard = UIStoryboard(name: "RequireLogin", bundle: nil)
            requireLoginNAV = storyboard.instantiateInitialViewController()! as? DefaultNavigationController
            requireLoginVC = requireLoginNAV!.childViewControllers[0] as? RequireLoginViewController
            requireLoginVC!.delegate = self
            requireLoginMainView = requireLoginNAV!.view
            requireLoginView = requireLoginVC!.view
            
            navigationController!.view.addSubview(requireLoginMainView!)
            
            requireLoginVC!.setupView(navTitle: "Notificaciones",
                                      descripcion: "Regístrate con tu perfil de Facebook o Google para ver las notificaciones de tus envíos.",
                                      imagen: UIImage(named: "ic_package_hand_100pt")!)
            
            /*print("Width: \(self.view.bounds.size.width)")
            print("Height: \(self.view.bounds.size.height)")
            print("Width: \(navigationController?.view.bounds.size.width)")
            print("Height: \(navigationController?.view.bounds.size.height)")
            print("Height: \(navigationController?.view.frame.size.height)")
            print("Child Height: \(requireLoginView!.bounds.size.height)")*/
            
            //requireLoginMainView!.frame = navigationController!.view.bounds
            
            requireLoginMainView!.frame = CGRect(x: 0,
                                                 y: 0, // self.view.bounds.size.height - requireLoginView!.bounds.size.height,
                width: self.view.bounds.size.width,
                height: navigationController!.view.bounds.size.height)
        } else {
            navigationController!.view.addSubview(requireLoginMainView!)
        }
    }
    
    @objc func refreshPulled() {
        fetchNotificaciones(showLoadingView: false)
    }

}

extension CentroNotificacionesTableViewController: RequireLoginDelegate {
    
    func iniciarSesionDidTap() {
        Helper.showLoginView(viewController: self)
    }
    
}

extension CentroNotificacionesTableViewController: NotificationHandlerDelegate {
    
    func userDidLogInNotificationHandler(notification: Notification) {
        DispatchQueue.main.async {
            self.requireLoginMainView?.removeFromSuperview()
        }
    }
    
    func userDidLogOutNotificationHandler(notification: Notification) {
        notificaciones = []
        tableView.reloadData()
        showRequireLoginView()
    }
    
}
