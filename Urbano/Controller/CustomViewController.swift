//
//  CustomViewController.swift
//  Urbano
//
//  Created by Mick VE on 10/03/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import UIKit

class CustomViewController: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var indicator: ActivityIndicator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*activityIndicator.hidesWhenStopped = true
        //let color: UIColor = UIColor(red: CGFloat(209/255.0), green: CGFloat(51/255.0), blue: CGFloat(57/255.0), alpha: CGFloat(1.0) )
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        addActivityIndicatorToView(activityIndicator: activityIndicator, view: self.view)
        //view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
 */
        // Do any additional setup after loading the view.
        indicator = ActivityIndicator(view: self.view, navigationController: nil, tabBarController: nil)
        indicator!.showActivityIndicator(withLabel: true, indicatorViewStyle: .gray)
    }
    
    func addActivityIndicatorToView(activityIndicator: UIActivityIndicatorView, view: UIView){
        self.view.addSubview(activityIndicator)
        
        //Don't forget this line
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        activityIndicator.startAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    struct ActivityIndicator {
        let viewForActivityIndicator = UIView()
        let view: UIView
        let navigationController: UINavigationController?
        let tabBarController: UITabBarController?
        let activityIndicatorView = UIActivityIndicatorView()
        let loadingTextLabel = UILabel()
        
        var navigationBarHeight: CGFloat { return navigationController?.navigationBar.frame.size.height ?? 0.0 }
        var tabBarHeight: CGFloat { return tabBarController?.tabBar.frame.height ?? 0.0 }
        
        func showActivityIndicator(withLabel: Bool, indicatorViewStyle: UIActivityIndicatorViewStyle) {
/*            viewForActivityIndicator.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
            viewForActivityIndicator.backgroundColor = UIColor.white
            view.addSubview(viewForActivityIndicator)
            activityIndicatorView.center = CGPoint(x: self.view.frame.size.width / 2.0, y: (self.view.frame.size.height - tabBarHeight - navigationBarHeight) / 2.0)*/

            view.addSubview(viewForActivityIndicator)
            viewForActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraint(NSLayoutConstraint(item: viewForActivityIndicator, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: viewForActivityIndicator, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
            
            if withLabel {
                loadingTextLabel.textColor = UIColor.darkGray
                loadingTextLabel.text = "CARGANDO"
                loadingTextLabel.font = UIFont(name: "Avenir Light", size: 11)
                loadingTextLabel.sizeToFit()
                loadingTextLabel.center = CGPoint(x: activityIndicatorView.center.x, y: activityIndicatorView.center.y + 25)
                viewForActivityIndicator.addSubview(loadingTextLabel)
            }
            
            activityIndicatorView.hidesWhenStopped = true
            activityIndicatorView.activityIndicatorViewStyle = indicatorViewStyle
            viewForActivityIndicator.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
        }
        
        func stopActivityIndicator() {
            viewForActivityIndicator.removeFromSuperview()
            activityIndicatorView.stopAnimating()
            activityIndicatorView.removeFromSuperview()
        }
    }

}
