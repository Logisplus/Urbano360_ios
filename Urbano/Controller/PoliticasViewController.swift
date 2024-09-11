//
//  PoliticasViewController.swift
//  Urbano
//
//  Created by Mick VE on 16/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import WebKit

class PoliticasViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var politicasWebView: WKWebView!
    
    let activityIndicatorView = UIActivityIndicatorView()
    
    var country: API.Country?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupActivityIndicatorView()
        setupWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicatorView.stopAnimating()
        setupAceptarPoliticasButton()
    }
    
    func setupWebView() {
        self.politicasWebView.navigationDelegate = self
        
        let url = URL(string: getURL())
        let request = URLRequest(url: url!)
        self.politicasWebView.load(request)
    }
    
    func setupActivityIndicatorView() {
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.activityIndicatorViewStyle = .gray
        //let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let barButton = UIBarButtonItem(customView: activityIndicatorView)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        activityIndicatorView.startAnimating()
    }
    
    func setupAceptarPoliticasButton() {
        let barButton = UIBarButtonItem(title: "Aceptar", style: .plain, target: self, action: #selector(aceptarPoliticasButtonDidTap))
        self.navigationItem.setRightBarButton(barButton, animated: true)
    }
    
    func getURL() -> String {
        switch country! {
        case .Chile:
            return Constant.URLPoliticas.Chile.rawValue
        case .Ecuador:
            return Constant.URLPoliticas.Ecuador.rawValue
        case .Peru:
            return Constant.URLPoliticas.Peru.rawValue
        }
    }
    
    @objc func aceptarPoliticasButtonDidTap(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Términos y Condiciones", message: "¿Acepta la política de privacidad y las condiciones de uso?", preferredStyle: .alert)
        
        let aceptoAction = UIAlertAction(title: "Acepto", style: .default) { (action: UIAlertAction) in
            UserDefaultsManager.shared.country = self.country
            NetworkManager.shared().buildAPI(country: self.country!.rawValue)
            
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let vc = sb.instantiateInitialViewController()!
            vc.view.frame = UIScreen.main.bounds
            UIView.transition(with: UIApplication.shared.keyWindow!, duration: 0.5, options: .transitionCrossDissolve, animations: {
                UIApplication.shared.keyWindow!.rootViewController = vc
            }, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        
        alert.addAction(aceptoAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

}
