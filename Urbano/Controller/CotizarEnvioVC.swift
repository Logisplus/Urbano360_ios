//
//  CotizarEnviioVC.swift
//  Urbano
//
//  Created by Mick VE on 7/09/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit
import AudioToolbox

class CotizarEnvioVC: UIViewController, UITextFieldDelegate, CotizarEnvioVCDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var boxCotizarEnvioView: UIView!
    
    @IBOutlet weak var boxInputPeso: UIView!
    @IBOutlet weak var boxInputMedida: UIView!
    @IBOutlet weak var boxCheckAsegurarEnvio: UIView!
    @IBOutlet weak var boxInputDeclararValorEnvio: UIView!
    
    @IBOutlet weak var boxBorderInputOrigen: UIView!
    @IBOutlet weak var boxBorderInputDestino: UIView!
    @IBOutlet weak var boxBorderInputPeso: UIView!
    @IBOutlet weak var boxBorderInputMedidas: UIView!
    @IBOutlet weak var boxBorderInputDeclararValorEnvio: UIView!
    
    @IBOutlet weak var errorInputPesoLabel: UILabel!
    @IBOutlet weak var errorInputMedidasLabel: UILabel!
    @IBOutlet weak var errorInputDeclararValorEnvioLabel: UILabel!
    
    @IBOutlet weak var tituloAsegurarEnvioLabel: UILabel!
    
    @IBOutlet weak var ciudadOrigenTextField: UILabel!
    @IBOutlet weak var ciudadDestinoTextField: UILabel!
    @IBOutlet weak var pesoTextField: UITextField!
    @IBOutlet weak var medidaAnchoTextField: UITextField!
    @IBOutlet weak var medidaAltoTextField: UITextField!
    @IBOutlet weak var medidaLargoTextField: UITextField!
    @IBOutlet weak var valorEnvioTextField: UITextField!
    
    @IBOutlet weak var tipoProductoSegmentedControl: UISegmentedControl!
    @IBOutlet weak var asegurarEnvioSwitch: UISwitch!
    
    @IBOutlet weak var cotizarEnvioButton: UIButton!
    
    var activeTextField: UITextField?
    
    var prevButtonKeyboardToolbar = UIBarButtonItem()
    var nextButtonKeyboardToolbar = UIBarButtonItem()
    
    var tipoCiudadSelected = -1
    var tipoProductoSelected = 0
    
    var ciudadOrigen: FetchDistritosPorDepartamentoResponse.Distrito?
    var ciudadDestino: FetchDistritosPorDepartamentoResponse.Distrito?
    
    var resultadoCotizacion: FetchCotizarEnvioResponse.ResultadoCotizacion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueToBuscarOrigenDestino" {
            let vc = segue.destination as! BuscarOrigenDestinoTableViewController
            vc.delegate = self
            vc.title = tipoCiudadSelected == 1 ? "Selecciona el origen" : "Selecciona el destino"
        } else if segue.identifier == "segueToResultadoCotizacion" {
            let vc = segue.destination as! ResultadoCotizacionVC
            vc.ciudadOrigen = ciudadOrigen
            vc.ciudadDestino = ciudadDestino
            vc.tipoProductoSelected = tipoProductoSelected
            vc.asegurarEnvioSelected = asegurarEnvioSwitch.isOn
            vc.pesoPaquete = pesoTextField.text!
            vc.anchoPaquete = medidaAnchoTextField.text!
            vc.altoPaquete = medidaAltoTextField.text!
            vc.largoPaquete = medidaLargoTextField.text!
            vc.valorDeclarado = valorEnvioTextField.text!
            vc.resultadoCotizacion = resultadoCotizacion
        }
    }
    
    // MARK: - TextField
    
    @objc func inputTextFieldDidChange(_ textField: UITextField) {
        switch textField.tag {
        case 1:
            changeColorBorderBoxInput(view: boxBorderInputPeso, color: "default")
            setVisibilityErrorLabel(label: self.errorInputPesoLabel, isHidden: true)
        case 2, 3, 4:
            let ancho = medidaAnchoTextField.text!.isEmpty ? 0.0 : Double(medidaAnchoTextField.text!)!
            let alto = medidaAltoTextField.text!.isEmpty ? 0.0 : Double(medidaAltoTextField.text!)!
            let largo = medidaLargoTextField.text!.isEmpty ? 0.0 : Double(medidaLargoTextField.text!)!
            
            if ancho > 200.0 || alto > 200.0 || largo > 200.0 {
                changeColorBorderBoxInput(view: boxBorderInputMedidas, color: "red")
                setVisibilityErrorLabel(label: self.errorInputMedidasLabel, isHidden: false)
            } else {
                changeColorBorderBoxInput(view: boxBorderInputMedidas, color: "default")
                setVisibilityErrorLabel(label: self.errorInputMedidasLabel, isHidden: true)
            }
        case 5:
            changeColorBorderBoxInput(view: boxBorderInputDeclararValorEnvio, color: "default")
            setVisibilityErrorLabel(label: self.errorInputDeclararValorEnvioLabel, isHidden: true)
        default:
            break
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.count + string.count - range.length
        
        /*if string.rangeOfCharacter(from: CharacterSet(charactersIn: ".")) != nil {
            return false
        }*/
        
        switch textField.tag {
        case 1, 2, 3, 4:
            return newLength <= 3
        case 5:
            return newLength <= 10
        default:
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
        
        switch textField.tag {
        case 1:
            prevButtonKeyboardToolbar.isEnabled = false
            nextButtonKeyboardToolbar.isEnabled = true
        case 2, 3:
            prevButtonKeyboardToolbar.isEnabled = true
            nextButtonKeyboardToolbar.isEnabled = true
        case 4:
            prevButtonKeyboardToolbar.isEnabled = true
            if asegurarEnvioSwitch.isOn {
                nextButtonKeyboardToolbar.isEnabled = true
            } else {
                nextButtonKeyboardToolbar.isEnabled = false
            }
        case 5:
            prevButtonKeyboardToolbar.isEnabled = true
            nextButtonKeyboardToolbar.isEnabled = false
        default:
            return
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeTextField = nil
    }
    
    /*func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.rangeOfCharacter(from: CharacterSet.letters) == nil
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return string.rangeOfCharacter(from: CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")) == nil
    }*/
    
    func ciudadDidSelect(ciudad: FetchDistritosPorDepartamentoResponse.Distrito) {
        if tipoCiudadSelected == 1 {
            ciudadOrigen = ciudad
            ciudadOrigenTextField.text = "\(ciudad.distrito.capitalized), \(ciudad.provincia.capitalized), \(ciudad.departamento.capitalized)"
            changeColorBorderBoxInput(view: boxBorderInputOrigen, color: "default")
        } else {
            ciudadDestino = ciudad
            ciudadDestinoTextField.text = "\(ciudad.distrito.capitalized), \(ciudad.provincia.capitalized), \(ciudad.departamento.capitalized)"
            changeColorBorderBoxInput(view: boxBorderInputDestino, color: "default")
        }
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tipoProductoDidChange(_ sender: UISegmentedControl) {
        view.endEditing(true)
        
        tipoProductoSelected = sender.selectedSegmentIndex
        
        switch sender.selectedSegmentIndex {
        case 0:
            UIView.animate(withDuration: 0.25) {
                self.boxInputPeso.alpha = 1
                self.boxInputMedida.alpha = 1
                self.boxCheckAsegurarEnvio.alpha = 1
                self.boxInputPeso.isHidden = false
                self.boxInputMedida.isHidden = false
                self.boxCheckAsegurarEnvio.isHidden = false
                if self.asegurarEnvioSwitch.isOn {
                    self.boxInputDeclararValorEnvio.alpha = 1
                    self.boxInputDeclararValorEnvio.isHidden = false
                }
            }
        case 1:
            UIView.animate(withDuration: 0.25) {
                self.boxInputPeso.alpha = 0
                self.boxInputMedida.alpha = 0
                self.boxCheckAsegurarEnvio.alpha = 0
                self.boxInputPeso.isHidden = true
                self.boxInputMedida.isHidden = true
                self.boxCheckAsegurarEnvio.isHidden = true
                if self.asegurarEnvioSwitch.isOn {
                    self.boxInputDeclararValorEnvio.alpha = 0
                    self.boxInputDeclararValorEnvio.isHidden = true
                }
            }
        default: break
        }
    }
    
    @IBAction func asegurarEnvioDidChange(_ sender: UISwitch) {
        if let _ = activeTextField {
            if activeTextField!.tag == 4 {
                nextButtonKeyboardToolbar.isEnabled = sender.isOn
            }
            if activeTextField!.tag == 5 {
                if !sender.isOn {
                    view.endEditing(true)
                }
            }
        }
        
        if sender.isOn {
            UIView.animate(withDuration: 0.25) {
                self.boxInputDeclararValorEnvio.alpha = 1
                self.boxInputDeclararValorEnvio.isHidden = false
            }
        } else {
            UIView.animate(withDuration: 0.25) {
                self.boxInputDeclararValorEnvio.alpha = 0
                self.boxInputDeclararValorEnvio.isHidden = true
            }
        }
    }
    
    @IBAction func cotizarEnvioDidTap(_ sender: UIButton) {
        if validateDatosCotizar() {
            cotizarEnvioRequest()
        }
    }
    
    @objc func didTapView(_ gesture: UIGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func buttonOrigenDidTap(_ gesture: UIGestureRecognizer) {
        tipoCiudadSelected = 1
        performSegue(withIdentifier: "segueToBuscarOrigenDestino", sender: nil)
    }
    
    @objc func buttonDestinoDidTap(_ gesture: UIGestureRecognizer) {
        tipoCiudadSelected = 2
        performSegue(withIdentifier: "segueToBuscarOrigenDestino", sender: nil)
    }
    
    @objc func prevButtonKeyboardToolbarDidSelect() {
        if let _ = activeTextField {
            switch activeTextField!.tag {
            case 2:
                pesoTextField.becomeFirstResponder()
            case 3:
                medidaAnchoTextField.becomeFirstResponder()
            case 4:
                medidaAltoTextField.becomeFirstResponder()
            case 5:
                medidaLargoTextField.becomeFirstResponder()
            default:
                return
            }
        }
    }
    
    @objc func nextButtonKeyboardToolbarDidSelect() {
        if let _ = activeTextField {
            switch activeTextField!.tag {
            case 1:
                medidaAnchoTextField.becomeFirstResponder()
            case 2:
                medidaAltoTextField.becomeFirstResponder()
            case 3:
                medidaLargoTextField.becomeFirstResponder()
            case 4:
                valorEnvioTextField.becomeFirstResponder()
            default:
                return
            }
        }
    }
    
    // MARK: Setup views
    
    func setupViews() {
        addShadowWithRoundedCorners(view: boxCotizarEnvioView)
        
        addBorderBoxInput(view: boxBorderInputOrigen)
        addBorderBoxInput(view: boxBorderInputDestino)
        addBorderBoxInput(view: boxBorderInputPeso)
        addBorderBoxInput(view: boxBorderInputMedidas)
        addBorderBoxInput(view: boxBorderInputDeclararValorEnvio)
        
        tipoProductoSegmentedControl.tintColor = ColorPalette.Urbano.rojo
        asegurarEnvioSwitch.onTintColor = ColorPalette.Urbano.rojo
        
        pesoTextField.tintColor = ColorPalette.Urbano.rojo
        medidaAnchoTextField.tintColor = ColorPalette.Urbano.rojo
        medidaAltoTextField.tintColor = ColorPalette.Urbano.rojo
        medidaLargoTextField.tintColor = ColorPalette.Urbano.rojo
        valorEnvioTextField.tintColor = ColorPalette.Urbano.rojo
        
        pesoTextField.delegate = self
        medidaAnchoTextField.delegate = self
        medidaAltoTextField.delegate = self
        medidaLargoTextField.delegate = self
        valorEnvioTextField.delegate = self
        
        let toolbar = UIToolbar();
        toolbar.tintColor = ColorPalette.Urbano.rojo
        toolbar.sizeToFit()
        
        prevButtonKeyboardToolbar = UIBarButtonItem(image: UIImage(named: "ic_arrow_left_grey_25pt"), style: .plain, target: self, action: #selector(prevButtonKeyboardToolbarDidSelect))
        nextButtonKeyboardToolbar = UIBarButtonItem(image: UIImage(named: "ic_arrow_right_grey_25pt"), style: .plain, target: self, action: #selector(nextButtonKeyboardToolbarDidSelect))
        let doneButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(didTapView))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolbar.setItems([prevButtonKeyboardToolbar, nextButtonKeyboardToolbar, spaceButton, doneButton], animated: false)
        
        pesoTextField.inputAccessoryView = toolbar
        medidaAnchoTextField.inputAccessoryView = toolbar
        medidaAltoTextField.inputAccessoryView = toolbar
        medidaLargoTextField.inputAccessoryView = toolbar
        valorEnvioTextField.inputAccessoryView = toolbar
        
        pesoTextField.addTarget(self, action: #selector(self.inputTextFieldDidChange(_:)), for: .editingChanged)
        medidaAnchoTextField.addTarget(self, action: #selector(self.inputTextFieldDidChange(_:)), for: .editingChanged)
        medidaAltoTextField.addTarget(self, action: #selector(self.inputTextFieldDidChange(_:)), for: .editingChanged)
        medidaLargoTextField.addTarget(self, action: #selector(self.inputTextFieldDidChange(_:)), for: .editingChanged)
        valorEnvioTextField.addTarget(self, action: #selector(self.inputTextFieldDidChange(_:)), for: .editingChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        view.addGestureRecognizer(tapGesture)
        
        cotizarEnvioButton.layer.cornerRadius = 8
        
        let inputOrigenTapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonOrigenDidTap(_:)))
        boxBorderInputOrigen.addGestureRecognizer(inputOrigenTapGesture)
        
        let inputDestinoTapGesture = UITapGestureRecognizer(target: self, action: #selector(buttonDestinoDidTap(_:)))
        boxBorderInputDestino.addGestureRecognizer(inputDestinoTapGesture)
        
        let backItem = UIBarButtonItem()
        backItem.title = "Atrás"
        navigationItem.backBarButtonItem = backItem
        
        switch UserDefaultsManager.shared.country! {
        case .Chile:
            tituloAsegurarEnvioLabel.text = "Declara el valor que estas enviando ($)"
        case .Ecuador:
            tituloAsegurarEnvioLabel.text = "Declara el valor que estas enviando ($)"
        case .Peru:
            tituloAsegurarEnvioLabel.text = "Declara el valor que estas enviando (S/)"
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillShow, object: nil, queue: nil) { (notification) in
            self.keyboardWillShow(notification: notification)
        }
        NotificationCenter.default.addObserver(forName: .UIKeyboardWillHide, object: nil, queue: nil) { (notification) in
            self.keyboardWillHide(notification: notification)
        }
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        
        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        scrollView.contentInset = contentInset
    }
    
    func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    func validateDatosCotizar() -> Bool {
        var validate = true
        
        if ciudadOrigen == nil {
            validate = false
            changeColorBorderBoxInput(view: boxBorderInputOrigen, color: "red")
        }
        
        if ciudadDestino == nil {
            validate = false
            changeColorBorderBoxInput(view: boxBorderInputDestino, color: "red")
        }
        
        if tipoProductoSelected == 0 {
            if !pesoTextField.text!.isEmpty {
                let peso = pesoTextField.text!.isEmpty ? 0.0 : Double(pesoTextField.text!)!
                
                if peso > 100.0 {
                    validate = false
                    changeColorBorderBoxInput(view: boxBorderInputPeso, color: "red")
                    setVisibilityErrorLabel(label: self.errorInputPesoLabel, isHidden: false)
                }
            } else {
                validate = false
                changeColorBorderBoxInput(view: boxBorderInputPeso, color: "red")
                setVisibilityErrorLabel(label: self.errorInputPesoLabel, isHidden: true)
            }
            
            if !medidaAnchoTextField.text!.isEmpty && !medidaAltoTextField.text!.isEmpty && !medidaLargoTextField.text!.isEmpty {
                let ancho = medidaAnchoTextField.text!.isEmpty ? 0.0 : Double(medidaAnchoTextField.text!)!
                let alto = medidaAltoTextField.text!.isEmpty ? 0.0 : Double(medidaAltoTextField.text!)!
                let largo = medidaLargoTextField.text!.isEmpty ? 0.0 : Double(medidaLargoTextField.text!)!
                
                if ancho > 200.0 || alto > 200.0 || largo > 200.0 {
                    validate = false
                    changeColorBorderBoxInput(view: boxBorderInputMedidas, color: "red")
                    setVisibilityErrorLabel(label: self.errorInputMedidasLabel, isHidden: false)
                }
            } else {
                validate = false
                changeColorBorderBoxInput(view: boxBorderInputMedidas, color: "red")
                setVisibilityErrorLabel(label: self.errorInputMedidasLabel, isHidden: true)
            }
            
            if asegurarEnvioSwitch.isOn {
                if !valorEnvioTextField.text!.isEmpty {
                    let valorEnvio = valorEnvioTextField.text!.isEmpty ? 0 : Int(valorEnvioTextField.text!)!
                    
                    if valorEnvio > getMontoMaximoValorEnvio() {
                        validate = false
                        changeColorBorderBoxInput(view: boxBorderInputDeclararValorEnvio, color: "red")
                        
                        switch UserDefaultsManager.shared.country! {
                        case .Chile, .Ecuador:
                            self.errorInputDeclararValorEnvioLabel.text = "El monto máximo para declarar es de $ \(getMontoMaximoValorEnvio())."
                        case .Peru:
                            self.errorInputDeclararValorEnvioLabel.text = "El monto máximo para declarar es de S/ \(getMontoMaximoValorEnvio())."
                        }
                        
                        setVisibilityErrorLabel(label: self.errorInputDeclararValorEnvioLabel, isHidden: false)
                    }
                } else {
                    validate = false
                    changeColorBorderBoxInput(view: boxBorderInputDeclararValorEnvio, color: "red")
                    setVisibilityErrorLabel(label: self.errorInputDeclararValorEnvioLabel, isHidden: true)
                }
            }
        }
        
        if !validate {
            let alertController = UIAlertController(title: "Ingresa correctamente los datos.",
                                                    message: nil,
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in }
            
            alertController.addAction(action)
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            self.present(alertController, animated: true, completion: nil)
        }
        
        return validate
    }
    
    func getMontoMaximoValorEnvio() -> Int {
        switch UserDefaultsManager.shared.country! {
        case .Chile:
            return 1000000
        case .Ecuador, .Peru:
            return 10000
        }
    }
    
    func addShadowWithRoundedCorners(view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 15)
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 15
    }
    
    func addBorderBoxInput(view: UIView) {
        view.layer.cornerRadius = 3
        view.layer.borderColor = UIColor(red: CGFloat(242.0/255.0), green: CGFloat(242.0/255.0), blue: CGFloat(242.0/255.0), alpha: CGFloat(1.0)).cgColor
        view.layer.borderWidth = 1
    }
    
    func changeColorBorderBoxInput(view: UIView, color: String) {
        if color == "default" {
            view.layer.cornerRadius = 3
            view.layer.borderColor = UIColor(red: CGFloat(242.0/255.0), green: CGFloat(242.0/255.0), blue: CGFloat(242.0/255.0), alpha: CGFloat(1.0)).cgColor
            view.layer.borderWidth = 1
        } else if color == "red" {
            view.layer.cornerRadius = 3
            view.layer.borderColor = ColorPalette.Urbano.rojo.cgColor
            view.layer.borderWidth = 1
        }
    }
    
    func setVisibilityErrorLabel(label: UILabel, isHidden: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            if label.isHidden && isHidden == false {
                label.isHidden = false
            }
            
            if !label.isHidden && isHidden == true {
                label.isHidden = true
            }
        }) { (finished) in
            UIView.animate(withDuration: 0.1) {
                if label.isHidden {
                    label.alpha = 0
                } else {
                    label.alpha = 1
                }
            }
        }
    }
    
    func cotizarEnvioRequest() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        
        var params: FetchCotizarEnvioRequest
        
        if tipoProductoSelected == 0 {
            params = FetchCotizarEnvioRequest(idCiudadOrigen: ciudadOrigen!.ciu_id,
                                              idCiudadDestino: ciudadDestino!.ciu_id,
                                              tipoProducto: "1",
                                              pesoPaquete: pesoTextField.text!,
                                              anchoPaquete: medidaAnchoTextField.text!,
                                              altoPaquete: medidaAltoTextField.text!,
                                              largoPaquete: medidaLargoTextField.text!,
                                              valorDeclarado: asegurarEnvioSwitch.isOn ? valorEnvioTextField.text! : "0",
                                              idUsuario: UserSession.getUserSessionID())
        } else {
            params = FetchCotizarEnvioRequest(idCiudadOrigen: ciudadOrigen!.ciu_id,
                                              idCiudadDestino: ciudadDestino!.ciu_id,
                                              tipoProducto: "2",
                                              pesoPaquete: "",
                                              anchoPaquete: "",
                                              altoPaquete: "",
                                              largoPaquete: "",
                                              valorDeclarado: "",
                                              idUsuario: UserSession.getUserSessionID())
        }
        
        DispatchQueue.main.async {
            self.present(loadingViewController, animated: true) {
                DispatchQueue.global().async {
                    API.cotizarEnvio(params: params) { (data, error) in
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
                                    
                                    /*let alertController = UIAlertController(title: "La reprogramación de visita fue registrada exitosamente.",
                                     message: "",
                                     preferredStyle: .alert)
                                     
                                     let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                                     //self.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
                                     //self.navigationController?.popToRootViewController(animated: true)
                                     self.navigationController?.dismiss(animated: true, completion: nil)
                                     }
                                     
                                     alertController.addAction(action)
                                     self.present(alertController, animated: true, completion: nil)*/
                                    
                                    self.resultadoCotizacion = data.data[0]
                                    self.performSegue(withIdentifier: "segueToResultadoCotizacion", sender: nil)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
}
