//
//  CalificarServicioVC.swift
//  Urbano
//
//  Created by Mick VE on 1/05/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class CalificarServicioVC: UITableViewController {
    
    var guiaNumero: String?
    var lineaNegocio: String?
    
    var isLoading = true
    var isEditable = true
    
    var comentario = ""
    var rating = 0
    
    var nombreCalificaciones = ["Malo", "Regular", "Bueno", "Optimo", "Excelente"]
    
    var detalleCalificacion: FetchDetalleCalificacionServicioResponse.DetalleCalificacion?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        self.tableView.register(UINib(nibName: "TextViewTableViewCell", bundle: nil), forCellReuseIdentifier: "inputCell")
        self.tableView.register(UINib(nibName: "RatingTableViewCell", bundle: nil), forCellReuseIdentifier: "ratingCell")
        
        fetchDetalleCalificacionServicio()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isLoading ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 0 : 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ratingCell", for: indexPath) as! RatingTableViewCell
            cell.floatRatingView.delegate = self
            if let calificacion = detalleCalificacion {
                cell.floatRatingView.rating = Double(calificacion.cant_estrellas)!
                cell.floatRatingView.editable = false
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! TextViewTableViewCell
            cell.textView.tintColor = ColorPalette.Urbano.rojo
            cell.textView.keyboardType = .default
            cell.textView.returnKeyType = .default
            cell.textView.delegate = self
            
            if let calificacion = detalleCalificacion {
                cell.textView.text = calificacion.apuntes
                cell.textView.textColor = ColorPalette.Urbano.negro
                cell.textView.isEditable = false
            } else {
                cell.textView.text = "Escribe un breve comentario (opcional)"
                cell.textView.textColor = UIColor.lightGray
            }
            
            
            /*cell.inputTextField.clearButtonMode = .whileEditing
            cell.inputTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
            cell.inputTextField.delegate = self
            cell.inputTextField.placeholder = "Escribe un breve comentario (opcional)"
            cell.inputTextField.textContentType = UITextContentType.emailAddress
            cell.inputTextField.keyboardType = .emailAddress
            cell.inputTextField.returnKeyType = .default*/
            //cell.inputTextField.text = dataNotificacion!.correo
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row == 0 ? 44.0 : 150.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 230.0
    }
    
    /*override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }*/
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = CalificarServicioHeaderView.instanceFromNib()
        
        if let calificacion = detalleCalificacion {
            view.titleLabel.text = "Calificación: \(nombreCalificaciones[Int(calificacion.cant_estrellas)! - 1])"
            view.descriptionLabel.text = "Tu calificación fue enviada el \(formatFecha(fecha: calificacion.fecha))"
        }
        
        return view
    }
    
    @objc func leftButtonDidTap(_ sender: Any) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func rightButtonDidTap(_ sender: Any) {
        if let _ = detalleCalificacion {
            dismiss(animated: true, completion: nil)
        } else {
            uploadCalificacionServicio()
        }
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func fetchDetalleCalificacionServicio() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        
        let params = FetchDetalleCalificacionServicioRequest(guiNumero: self.guiaNumero!,
                                                             lineaNegocio: self.lineaNegocio!,
                                                             idUsuario: UserSession.getUserSessionID())
        
        DispatchQueue.main.async {
            self.present(loadingViewController, animated: true) {
                DispatchQueue.global().async {
                    API.getDetalleCalificacionServicio(params: params) { (data, error) in
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
                                    
                                    //self.processDataDetalleReprogramacion(detalleReprogramacion: data.data[0])
                                    self.processDataDetalleCalificacion(detalleCalificacion: data.data)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func uploadCalificacionServicio() {
        let loadingViewController = LoadingViewController(message: "Loading...")
        
        let params = UploadCalificacionServicioRequest(guiNumero: self.guiaNumero!,
                                                       estrellas: "\(rating)",
                                                       comentario: comentario,
                                                       lineaNegocio: self.lineaNegocio!,
                                                       idUsuario: UserSession.getUserSessionID())
        
        DispatchQueue.main.async {
            self.present(loadingViewController, animated: true) {
                DispatchQueue.global().async {
                    API.uploadCalificacionServicio(params: params) { (data, error) in
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
                                    
                                    let alertController = UIAlertController(title: "Tu calificación fue enviada exitosamente, muchas gracias por tu tiempo.",
                                                                            message: nil,
                                        preferredStyle: .alert)
                                    
                                    let action = UIAlertAction(title: "OK", style: .cancel) { (action:UIAlertAction) in
                                        self.dismiss(animated: true, completion: nil)
                                    }
                                    
                                    alertController.addAction(action)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func processDataDetalleCalificacion(detalleCalificacion: [FetchDetalleCalificacionServicioResponse.DetalleCalificacion]) {
        if detalleCalificacion.count == 0 {
            let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.leftButtonDidTap(_:)))
            self.navigationItem.leftBarButtonItem = leftButton
            
            let rightButton = UIBarButtonItem(title: "Enviar", style: .plain, target: self, action: #selector(self.rightButtonDidTap(_:)))
            self.navigationItem.rightBarButtonItem = rightButton
            self.navigationItem.rightBarButtonItem!.isEnabled = false
            
            isLoading = false
            self.tableView.reloadData()
        } else {
            self.detalleCalificacion = detalleCalificacion[0]
            
            let rightButton = UIBarButtonItem(title: "OK", style: .plain, target: self, action: #selector(self.rightButtonDidTap(_:)))
            self.navigationItem.rightBarButtonItem = rightButton
            
            isLoading = false
            self.tableView.reloadData()
        }
    }
    
    func formatFecha(fecha: String) -> String {
        var dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "es_ES")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: fecha) {
            dateFormatter.dateFormat = "dd"
            let day = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "EEEE"
            let dayName = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "MMMM"
            let monthName = dateFormatter.string(from: date)
            dateFormatter.dateFormat = "yyyy"
            let year = dateFormatter.string(from: date)
            return "\(dayName.capitalized), \(day) de \(monthName.capitalized) del \(year)"
        } else {
            return "Fecha no valida."
        }
    }
    
}

extension CalificarServicioVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
        
        if text == "Escribe un breve comentario (opcional)" {
            textView.text = ""
            textView.textColor = RastrearEnvioViewController.PalleteColorUrbano.negro
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let text = textView.text, text.count == 0 {
            textView.text = "Escribe un breve comentario (opcional)"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        comentario = textView.text
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let value = textView.text else { return true }
        let newLength = value.count + text.count - range.length
        return newLength <= 240
    }
    
}

extension CalificarServicioVC: FloatRatingViewDelegate {
    
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Double) {
        self.rating = Int(rating)
        
        if rating > 1 {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    
}
