//
//  ConfiguracionTableViewController.swift
//  Urbano
//
//  Created by Mick VE on 12/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import GoogleSignIn

class ConfiguracionTableViewController: UITableViewController {
    
    var menus = [[Menu]]()
    
    struct Menu {
        var title: String
        var subtitle: String?
        var icon: UIImage?
        var bgIcon: UIColor
        var action: MenuAction
    }
    
    enum MenuAction: Int {
        case AcercaDe
        case CotizarEnvio
        case CambiarPais
        case Contactanos
        case SignIn
        case SignOut
        case PerfilUsuario
    }
    
    var userPhotoImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        tableView.register(UINib(nibName: "MenuTableViewCell", bundle: nil), forCellReuseIdentifier: "menuCell")
        tableView.register(UINib(nibName: "UserMenuTableViewCell", bundle: nil), forCellReuseIdentifier: "userMenuCell")
        
        setupMenusViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidLogInNotificationHandler), name: Constant.NotificationName.UserDidLogIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.userDidLogOutNotificationHandler), name: Constant.NotificationName.UserDidLogOut, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //GIDSignIn.sharedInstance().uiDelegate = self
        //GIDSignIn.sharedInstance().delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueConfiguracionToAcercaDe" {
            let vc = segue.destination as! AcercaDeTableViewController
            vc.hidesBottomBarWhenPushed = true
        } else if segue.identifier == "segueConfiguracionToCambiarPais" {
            let vc = segue.destination as! CambiarDePaisTableViewController
            vc.hidesBottomBarWhenPushed = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return menus.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "userMenuCell", for: indexPath) as! UserMenuTableViewCell
            cell.setupMenu(menu: menus[indexPath.section][indexPath.row])
            
            if UserSession.isUserLogged() {
                if let _ = userPhotoImage {
                    cell.iconImage.image = self.userPhotoImage
                    cell.iconImage.layer.cornerRadius = 30
                    cell.iconImage.clipsToBounds = true
                } else {
                    let url = URL(string: UserDefaultsManager.shared.userSessionPhotoURL!)
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: url!)
                        DispatchQueue.main.async {
                            if let _ = data {
                                self.userPhotoImage = UIImage(data: data!)
                                cell.iconImage.image = self.userPhotoImage
                                cell.iconImage.layer.cornerRadius = 30
                                cell.iconImage.clipsToBounds = true
                            }
                        }
                    }
                }
            }
            
            return cell
        case 1, 2, 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath) as! MenuTableViewCell
            cell.setupMenu(menu: menus[indexPath.section][indexPath.row])
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "signOutMenuCell", for: indexPath)
            cell.textLabel?.text = menus[indexPath.section][indexPath.row].title
            cell.textLabel?.textColor = UIColor.red
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return CGFloat(75)
        default:
            return CGFloat(44)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch menus[indexPath.section][indexPath.row].action {
        case .AcercaDe:
            performSegue(withIdentifier: "segueConfiguracionToAcercaDe", sender: nil)
        case .CotizarEnvio:
            //performSegue(withIdentifier: "segueConfiguracionToAcercaDe", sender: nil)
            let storyboard = UIStoryboard(name: "CotizarEnvio", bundle: nil)
            let vc = storyboard.instantiateInitialViewController()!
            show(vc, sender: nil)
        case .CambiarPais:
            performSegue(withIdentifier: "segueConfiguracionToCambiarPais", sender: nil)
        case .Contactanos:
            var url: URL?
            switch UserDefaultsManager.shared.country! {
            case .Chile:
                url = URL(string: "mailto:customer.service@urbanoexpress.cl")
            case .Ecuador:
                url = URL(string: "mailto:comercial@urbano.com.ec")
            case .Peru:
                url = URL(string: "mailto:comercial@urbano.com.pe")
            }
            UIApplication.shared.open(url!)
        case .SignIn:
            Helper.showLoginView(viewController: self)
        case .SignOut:
            tableView.deselectRow(at: indexPath, animated: true)
            let alert = UIAlertController(title: "¿Seguro que quieres cerra la sesión?", message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
            let signOutAction = UIAlertAction(title: "Salir", style: .destructive) { (action:UIAlertAction) in
                UserSession.logout()
                
                self.setupMenusViews()
                self.tableView.reloadData()
                NotificationCenter.default.post(name: Constant.NotificationName.UserDidLogOut, object: nil)
            }
            alert.addAction(cancelAction)
            alert.addAction(signOutAction)
            
            if let popoverController = alert.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            present(alert, animated: true, completion: nil)
            break
        case .PerfilUsuario:
            break
        }
    }
    
    func setupMenusViews() {
        if UserSession.isUserLogged() {
            menus = [
                [Menu(title: UserDefaultsManager.shared.userSessionFullName!,
                      subtitle: UserDefaultsManager.shared.userSessionEmail!,
                      icon: UIImage(named: "ic_user_account_60pt"),
                      bgIcon: RastrearEnvioViewController.PalleteColorUrbano.gris, action: .PerfilUsuario)],
                //[Menu(title: "Cotizar envío", subtitle: nil, icon: UIImage(named: "ic_calculator_white_25pt"),
                      //bgIcon: UIColor(red: CGFloat(24.0/255.0), green: CGFloat(155.0/255.0), blue: CGFloat(72.0/255.0), alpha: CGFloat(1.0)), action: .CotizarEnvio)],
                [Menu(title: "Cambiar de país", subtitle: nil, icon: UIImage(named: "ic_earth_25pt"),
                      bgIcon: UIColor(red: CGFloat(227/255.0), green: CGFloat(117/255.0), blue: CGFloat(26/255.0), alpha: CGFloat(1.0)), action: .CambiarPais)],
                [Menu(title: "Contáctanos", subtitle: nil, icon: UIImage(named: "ic_email_25pt"),
                      bgIcon: RastrearEnvioViewController.PalleteColorUrbano.rojo, action: .Contactanos),
                 Menu(title: "Acerca de", subtitle: nil, icon: UIImage(named: "ic_letter_i_25pt"),
                      bgIcon: UIColor(red: CGFloat(26/255.0), green: CGFloat(136/255.0), blue: CGFloat(227/255.0), alpha: CGFloat(1.0)), action: .AcercaDe)],
                [Menu(title: "Cerrar sesión", subtitle: nil, icon: UIImage(named: "ic_email_25pt"),
                      bgIcon: RastrearEnvioViewController.PalleteColorUrbano.rojo, action: .SignOut)]]
        } else {
            menus = [
                [Menu(title: "Inicia sesión", subtitle: "Invitado", icon: UIImage(named: "ic_user_account_60pt"),
                      bgIcon: RastrearEnvioViewController.PalleteColorUrbano.gris, action: .SignIn)],
                //[Menu(title: "Cotizar envío", subtitle: nil, icon: UIImage(named: "ic_calculator_white_25pt"),
                      //bgIcon: UIColor(red: CGFloat(24.0/255.0), green: CGFloat(155.0/255.0), blue: CGFloat(72.0/255.0), alpha: CGFloat(1.0)), action: .CotizarEnvio)],
                [Menu(title: "Cambiar de país", subtitle: nil, icon: UIImage(named: "ic_earth_25pt"),
                      bgIcon: UIColor(red: CGFloat(227/255.0), green: CGFloat(117/255.0), blue: CGFloat(26/255.0), alpha: CGFloat(1.0)), action: .CambiarPais)],
                [Menu(title: "Contáctanos", subtitle: nil, icon: UIImage(named: "ic_email_25pt"),
                      bgIcon: RastrearEnvioViewController.PalleteColorUrbano.rojo, action: .Contactanos),
                 Menu(title: "Acerca de", subtitle: nil, icon: UIImage(named: "ic_letter_i_25pt"),
                      bgIcon: UIColor(red: CGFloat(26/255.0), green: CGFloat(136/255.0), blue: CGFloat(227/255.0), alpha: CGFloat(1.0)), action: .AcercaDe)]]
        }
    }
}

/*extension ConfiguracionTableViewController: GIDSignInUIDelegate, GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("USUARIO CONECTADO")
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("USUARIO DESCONECTADO")
    }
    
}*/

extension ConfiguracionTableViewController: NotificationHandlerDelegate {
    
    func userDidLogInNotificationHandler(notification: Notification) {
        setupMenusViews()
        tableView.reloadData()
    }
    
    func userDidLogOutNotificationHandler(notification: Notification) {
        setupMenusViews()
        tableView.reloadData()
    }
    
}
