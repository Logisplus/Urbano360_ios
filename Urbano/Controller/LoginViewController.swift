//
//  LoginViewController.swift
//  Urbano
//
//  Created by Mick VE on 17/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import GoogleSignIn
import FacebookCore
import FacebookLogin
import FirebaseMessaging

class LoginViewController: UIViewController {

    @IBOutlet weak var boxButtonFacebookView: UIView!
    @IBOutlet weak var boxButtonGoogleView: UIView!
    
    @IBOutlet weak var politicasTextView: UITextView!
    
    var loginViewDelegate: LoginViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = self
        
        view.backgroundColor = RastrearEnvioViewController.PalleteColorUrbano.negro
        
        setupSignInButton(view: boxButtonFacebookView, background: ColorPalette.Facebook)
        setupSignInButton(view: boxButtonGoogleView, background: UIColor.white)
        
        self.performLinkMaker()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func facebookButtonDidTap(_ sender: Any) {
        let loginManager = LoginManager()
        
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                NSLog(error.localizedDescription)
                break
            case .cancelled: break
            case .success(granted: let granted, declined: let declined, token: let token):
                if declined.count == 0 {
                    self.getFBUserData()
                } else {
                    self.showErrorLoginPopup()
                }
            }
        }
    }
    
    @IBAction func googleButtonDidTap(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func setupSignInButton(view: UIView, background color: UIColor) {
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        view.backgroundColor = color
    }
    
    func setupButtonLinks(button: UIButton, title: String) {
        let linkAttributes: [NSAttributedStringKey: Any] = [NSAttributedStringKey.foregroundColor: UIColor.white,
                                                            NSAttributedStringKey.underlineColor: UIColor.white,
                                                            NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
        
        let attributedString = NSMutableAttributedString(string: "")
        
        let buttonTitleStr = NSMutableAttributedString(string: title, attributes: linkAttributes)
        
        attributedString.append(buttonTitleStr)
        
        button.setAttributedTitle(attributedString, for: .normal)
    }
    
    func getURLPoliticas(country: API.Country) -> URL {
        switch country {
        case .Chile:
            return URL(string: Constant.URLPoliticas.Chile.rawValue)!
        case .Ecuador:
            return URL(string: Constant.URLPoliticas.Ecuador.rawValue)!
        case .Peru:
            return URL(string: Constant.URLPoliticas.Peru.rawValue)!
        }
    }
    
    func showErrorLoginPopup() {
        let alert = UIAlertController(title: "Conexión a perfil fallida",
                                     message: "Lo sentimos, no hemos podido conectar tu perfil con tu cuenta de Facebook.\nPor favor, inténtalo de nuevo.",
                                     preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func getFBUserData() {
        if let accessToken = AccessToken.current {
            // User is logged in, use 'accessToken' here.
            // ["fields":"email,first_name,last_name,picture.width(1000).height(1000),birthday,gender"]
            let graphRequestConnection = GraphRequestConnection()

            let graphRequest = GraphRequest(graphPath: "me",
                                            parameters: ["fields": "id, name, picture.type(large), email"],
                                            tokenString: accessToken.tokenString,
                                            version: Settings.defaultGraphAPIVersion,
                                            httpMethod: .get)
            
            graphRequestConnection.add(graphRequest) { (httpResponse, result, error) in
                if error != nil {
                    NSLog(error.debugDescription)
                    self.showErrorLoginPopup()
                    return
                }
                
                guard let responseDictionary = result as? NSDictionary else {
                    self.showErrorLoginPopup()
                    return
                }
                
                let fbId = responseDictionary["id"] as! String
                let email = responseDictionary["email"] as? String ?? ""
                let name = responseDictionary["name"] as? String ?? ""
                    
                var pictureUrl = ""
                if let picture = responseDictionary["picture"] as? NSDictionary,
                   let data = picture["data"] as? NSDictionary,
                   let url = data["url"] as? String {
                    pictureUrl = url
                }
                
                let params = UploadRegistroUsuarioRequest(userSessionIDOfPlatform: fbId,
                                                          userSessionPlatform: "\(UserSession.Platform.Facebook.rawValue)",
                                                          userSessionFullName: name,
                                                          userSessionEmail: email,
                                                          userSessionPhotoURL: pictureUrl,
                                                          userSessionPassword: "",
                                                          nameDevice: UIDevice.current.modelName,
                                                          nameOS: UIDevice.current.systemName,
                                                          versionOS: UIDevice.current.systemVersion,
                                                          fcmToken: Messaging.messaging().fcmToken ?? "There is'not token.")
                
                self.uploadRegistroUsuario(params: params)
                
                /*if let result = result as? [String:Any],
                    let email: String = result["email"] as? String,
                    let name: String = result["name"] as? String,
                    let fbId: String = result["id"] as? String {
                    
                } else {
                    NSLog("Error al obtener datos del perfil de facebook")
                }*/
            }
            
            graphRequestConnection.start()
        }
    }
    
    func uploadRegistroUsuario(params: UploadRegistroUsuarioRequest) {
        let loadingViewController = LoadingViewController(message: "Loading...")
        self.present(loadingViewController, animated: true, completion: nil)
        
        API.uploadRegistroUsuario(params: params) { (data, error) in
            DispatchQueue.main.async {
                loadingViewController.dismiss(animated: true, completion: {
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
                        
                        let profile = UserSession.Profile(userSessionID: data.data[0].user_id,
                                                                              userSessionIDOfPlatform: params.userSessionIDOfPlatform,
                                                                              userSessionPlatform: UserSession.Platform(rawValue: Int(params.userSessionPlatform)!)!,
                                                                              userSessionFullName: params.userSessionFullName,
                                                                              userSessionEmail: params.userSessionEmail,
                                                                              userSessionPhotoURL: params.userSessionPhotoURL,
                                                                              userSessionStatus: UserSession.Status.Logged)
                        
                        UserSession.saveUserData(userSessionProfile: profile)
                        NotificationCenter.default.post(name: Constant.NotificationName.UserDidLogIn, object: profile)
                        self.dismiss(animated: true, completion: nil)
                    }
                })
            }
        }
    }

}

class LoginNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = ColorPalette.Urbano.negro
        navigationBar.barStyle = .blackOpaque
        navigationBar.isTranslucent = false
        navigationBar.tintColor = UIColor.white
        navigationBar.shadowImage = UIImage()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension LoginViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        //UIApplication.shared.open(URL, options: [:])
        UIApplication.shared.open(URL)
        return false
    }
    
    func turnStringIntoLink(mutableAttributedString: NSMutableAttributedString, url: URL, range: NSRange) -> NSMutableAttributedString {
        mutableAttributedString.addAttribute(NSAttributedStringKey.link, value: url, range: range)
        //linkString.addAttribute(NSAttributedStringKey.font, value: UIFont(name: "Arial", size: 17.0)!, range: NSMakeRange(0, underscoredInputString.count))
        //linkString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 17, weight: .regular), range: NSMakeRange(0, underscoredInputString.count))
        mutableAttributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
        mutableAttributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.preferredFont(forTextStyle: .body), range: range)
        mutableAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: range)
        return mutableAttributedString
    }
    
    func turnStringStyleDefault(mutableAttributedString: NSMutableAttributedString, range: NSRange) -> NSMutableAttributedString {
        mutableAttributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.preferredFont(forTextStyle: .body), range: range)
        mutableAttributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: range)
        return mutableAttributedString
    }
    
    func turnTextViewPoliciesIntoLinks(politicas: String) -> NSMutableAttributedString {
        
        var mutableAttributedString = NSMutableAttributedString(string: "Al continuar, acepta que ha leído y aceptado la política de privacidad y las condiciones de uso.")
        
        mutableAttributedString = turnStringStyleDefault(mutableAttributedString: mutableAttributedString,
                                                         range: NSMakeRange(0, 47))
        
        mutableAttributedString = turnStringStyleDefault(mutableAttributedString: mutableAttributedString,
                                                         range: NSMakeRange(70, 7))
        
        mutableAttributedString = turnStringStyleDefault(mutableAttributedString: mutableAttributedString,
                                                         range: NSMakeRange(95, 1))

        mutableAttributedString = turnStringIntoLink(mutableAttributedString: mutableAttributedString,
                                                     url: getURLPoliticas(country: UserDefaultsManager.shared.country!),
                                                     range: NSMakeRange(48, 22))
        
        mutableAttributedString = turnStringIntoLink(mutableAttributedString: mutableAttributedString,
                                                     url: getURLPoliticas(country: UserDefaultsManager.shared.country!),
                                                     range: NSMakeRange(77, 18))
        
        return mutableAttributedString
    }
    
    func performLinkMaker() {
        self.politicasTextView.attributedText = self.turnTextViewPoliciesIntoLinks(politicas: self.politicasTextView.text!)
        self.politicasTextView.textAlignment = .center
        self.politicasTextView.tintColor = UIColor.white
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedTextView(_:)))
        self.politicasTextView.addGestureRecognizer(tapRecognizer)

    }
    
    @objc func tappedTextView(_ tapGesture: UIGestureRecognizer) {
        let textView = tapGesture.view as! UITextView
        let tapLocation = tapGesture.location(in: textView)
        let textPosition = textView.closestPosition(to: tapLocation)
        let attr = textView.textStyling(at: textPosition!, in: .forward)!
        
        if let url: URL = attr[NSAttributedStringKey.link.rawValue] as? URL {
            UIApplication.shared.open(url)
        }
    }
    
}

extension LoginViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            //let idToken = user.authentication.idToken // Safe to send to the server
            let photoURL = user.profile.imageURL(withDimension: 180)
            
            let params = UploadRegistroUsuarioRequest(userSessionIDOfPlatform: user.userID,
                                                      userSessionPlatform: "\(UserSession.Platform.Google.rawValue)",
                                                      userSessionFullName: user.profile.name,
                                                      userSessionEmail: user.profile.email,
                                                      userSessionPhotoURL: photoURL?.absoluteString ?? "",
                                                      userSessionPassword: "",
                                                      nameDevice: UIDevice.current.modelName,
                                                      nameOS: UIDevice.current.systemName,
                                                      versionOS: UIDevice.current.systemVersion,
                                                      fcmToken: Messaging.messaging().fcmToken ?? "There is'not token.")
            
            uploadRegistroUsuario(params: params)
        }
    }
    
}
