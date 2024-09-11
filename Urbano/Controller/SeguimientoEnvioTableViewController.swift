//
//  SeguimientoEnvioTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 9/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class SeguimientoEnvioTableViewController: UITableViewController {
    
    var envios = [FetchEnviosEnSeguimientoResponse.Envio]()
    
    let refreshCtrl = UIRefreshControl()
    
    var loadingView: LoadingViewController?
    
    var requireLoginNAV: DefaultNavigationController?
    var requireLoginVC: RequireLoginViewController?
    var requireLoginMainView: UIView?
    var requireLoginView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        //self.navigationController?.navigationBar.prefersLargeTitles = false
        //self.edgesForExtendedLayout = .all
        //self.tableView.contentInsetAdjustmentBehavior = .always
        //refreshControl = refreshControl
        
        refreshCtrl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.refreshControl = refreshCtrl
        tableView.register(UINib(nibName: "SeguimientoEnvioTableViewCell", bundle: nil), forCellReuseIdentifier: "seguimientoEnvioCell")
        
        setupNotificationHandlerDelegate()
        
        if UserSession.isUserLogged() {
            fetchEnviosEnSeguimiento(showLoadingView: true)
        } else {
            showRequireLoginView()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return envios.count > 0 ? 1 : 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return envios.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "seguimientoEnvioCell", for: indexPath) as! SeguimientoEnvioTableViewCell
        
        var cellStyle: SeguimientoEnvioTableViewCellStyle?
        var bgColorCell: UIColor?
        
        if let idCHK = Int(envios[indexPath.row].chk_id) {
            switch idCHK {
            case Constant.CHKControl.ENTREGADO:
                cellStyle = .color
                bgColorCell = RastrearEnvioViewController.PalleteColorUrbano.negro
            case Constant.CHKControl.NO_ENTREGADO, Constant.CHKControl.CLIENTE_VISITADO:
                cellStyle = .color
                bgColorCell = RastrearEnvioViewController.PalleteColorUrbano.rojo
            default:
                cellStyle = .default
                bgColorCell = UIColor.white
            }
        }
        
        cell.setupCellStyle(style: cellStyle!, bgColor: bgColorCell!)
        cell.setupEnvio(envio: envios[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "BuscarGuia", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RastrearEnvioStoryboard") as! RastrearEnvioViewController
        vc.searchGuia = envios[indexPath.row].barra
        vc.hidesBottomBarWhenPushed = true
        show(vc, sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let closeAction = UIContextualAction(style: .destructive, title: nil, handler: { (contextAction:UIContextualAction, sourceView:UIView, completionHandler: @escaping (Bool) -> Void) in
            let alertController = UIAlertController(title: "Quitar esta guía de seguimiento.",
                                                    message: nil,
                                                    preferredStyle: .actionSheet)
            let quitarAction = UIAlertAction(title: "Quitar", style: UIAlertActionStyle.destructive) { (action:UIAlertAction) in
                let params = SeguimientoEnvio.MarcarSeguimientoEnvio.Request(guiNumero: self.envios[indexPath.row].guia,
                                                                             estado: "0",
                                                                             lineaNegocio: self.envios[indexPath.row].linea,
                                                                             idUsuario: UserSession.getUserSessionID())
                
                self.quitarGuiaSeguimientoRequest(params: params, success: { (response) in
                    if response {
                        self.envios.remove(at: indexPath.row)
                        tableView.beginUpdates()
                        tableView.deleteRows(at: [indexPath], with: .left)
                        tableView.endUpdates()
                        completionHandler(true)
                    } else {
                        completionHandler(false)
                    }
                })
                
                /*self.envios.remove(at: indexPath.row)
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [indexPath], with: .left)
                self.tableView.endUpdates()
                completionHandler(true)*/
                
                /*CATransaction.begin()
                CATransaction.setCompletionBlock({
                    self.tableView.beginUpdates()
                    self.envios.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.left)
                    self.tableView.endUpdates()
                    //completionHandler(true)
                })
                self.tableView.setEditing(false, animated: true)
                CATransaction.commit()*/
            }
            
            let cancelAction = UIAlertAction(title: "Cancelar", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
                completionHandler(false)
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(quitarAction)
            self.present(alertController, animated: true, completion: nil)
        })

        closeAction.image = UIImage(named: "ic_pin_off_30pt")
        closeAction.backgroundColor = UIColor.red //UIColor(red: CGFloat(231/255.0), green: CGFloat(47/255.0), blue: CGFloat(56/255.0), alpha: CGFloat(1.0))
        return UISwipeActionsConfiguration(actions: [closeAction])
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    /*override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            envios.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }*/
    
    func fetchEnviosEnSeguimiento(showLoadingView: Bool) {
        loadingView = nil
        if showLoadingView {
            loadingView = LoadingViewController(message: "Loading...")
            self.present(loadingView!, animated: true, completion: nil)
        }
        
        let params = FetchEnviosEnSeguimientoRequest(idUsuario: UserSession.getUserSessionID())
        API.fetchEnviosEnSeguimiento(params: params) { (data, error) in
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
                        
                        self.loadDataForTableView(envios: data.data)
                        
                        DispatchQueue.main.async {
                            if data.data.count == 0 {
                                self.navigationItem.title = "Seguimiento"
                            } else {
                                self.navigationItem.title = "Seguimiento (\(data.data.count))"
                            }
                        }
                    }
                })
            }
        }
    }
    
    func quitarGuiaSeguimientoRequest(params: SeguimientoEnvio.MarcarSeguimientoEnvio.Request, success: @escaping (Bool) -> Void ) {
        let loadingViewController = LoadingViewController(message: "Loading...")
        self.present(loadingViewController, animated: true, completion: nil)
        
        API.marcarSeguimientoEnvio(params: params) { (data, error) in
            DispatchQueue.main.async {
                loadingViewController.dismiss(animated: true, completion: {
                    if let _ = error {
                        let alertController = UIAlertController(title: "Lo sentimos, ocurrió un error",
                                                                message: error,
                                                                preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                            success(false)
                        }
                        
                        alertController.addAction(action)
                        self.present(alertController, animated: true, completion: nil)
                        return
                    }
                    
                    if let data = data {
                        guard data.success else {
                            let alertController = UIAlertController(title: "Lo sentimos, ocurrió un error",
                                                                    message: "\(data.msg_error)",
                                preferredStyle: .alert)
                            
                            let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                                success(false)
                            }
                            
                            alertController.addAction(action)
                            self.present(alertController, animated: true, completion: nil)
                            return
                        }
                        
                        let alertController = UIAlertController(title: "Tu envío se quitó de seguimiento exitosamente.",
                                                                message: nil,
                                                                preferredStyle: .alert)
                        
                        let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                            success(true)
                        }
                        
                        alertController.addAction(action)
                        self.present(alertController, animated: true, completion: nil)
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
    
    func loadDataForTableView(envios: [FetchEnviosEnSeguimientoResponse.Envio]) {
        self.envios = envios
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
    
    func showRequireLoginView() {
        if requireLoginNAV == nil {
            let storyboard = UIStoryboard(name: "RequireLogin", bundle: nil)
            requireLoginNAV = storyboard.instantiateInitialViewController()! as? DefaultNavigationController
            requireLoginVC = requireLoginNAV!.childViewControllers[0] as? RequireLoginViewController
            requireLoginVC!.delegate = self
            requireLoginMainView = requireLoginNAV!.view
            requireLoginView = requireLoginVC!.view
            
            navigationController!.view.addSubview(requireLoginMainView!)
            
            requireLoginVC!.setupView(navTitle: "Seguimiento",
                                      descripcion: "Regístrate con tu perfil de Facebook o Google para realizar seguimiento de tus envíos.",
                                      imagen: UIImage(named: "ic_package_tumbril_100pt")!)
            
            requireLoginMainView!.frame = CGRect(x: 0,
                                                 y: 0,
                width: self.view.bounds.size.width,
                height: navigationController!.view.bounds.size.height)
        } else {
            navigationController!.view.addSubview(requireLoginMainView!)
        }
    }
    
    @objc func refreshPulled() {
        fetchEnviosEnSeguimiento(showLoadingView: false)
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [refreshCtrl] in
            self.refreshCtrl.endRefreshing()
        }*/
    }

}

extension SeguimientoEnvioTableViewController: RequireLoginDelegate {
    
    func iniciarSesionDidTap() {
        Helper.showLoginView(viewController: self)
    }
    
}

extension SeguimientoEnvioTableViewController: NotificationHandlerDelegate {
    
    func userDidLogInNotificationHandler(notification: Notification) {
        DispatchQueue.main.async {
            self.requireLoginMainView?.removeFromSuperview()
        }
    }
    
    func userDidLogOutNotificationHandler(notification: Notification) {
        envios = []
        tableView.reloadData()
        showRequireLoginView()
    }
    
}
