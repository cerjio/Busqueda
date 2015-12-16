//
//  ViewController.swift
//  Busqueda
//
//  Created by cerjio on 15/12/15.
//  Copyright © 2015 cerjio. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UISearchBarDelegate, UITextViewDelegate {

    @IBOutlet weak var isbnBar: UISearchBar!
    @IBOutlet weak var resultado: UITextView!
    @IBOutlet weak var isbnEtiqueta: UILabel!
    let urlString : String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isbnBar.delegate = self
        resultado.delegate = self
        resultado.layer.borderColor = UIColor.blueColor().CGColor
        resultado.layer.borderWidth = 1.0
        resultado.layer.cornerRadius = 5.0
        resultado.hidden = true
        isbnEtiqueta.text = String("")
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate:nil, delegateQueue:NSOperationQueue.mainQueue())
        let finalURL = urlString + isbnBar.text!
        let url = NSURL(string: finalURL)
        let request = NSURLRequest(URL: url!)
        
        let dataTask = session.dataTaskWithRequest(request) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            
            if error != nil {
                
                self.isbnEtiqueta.text = String("")
                self.resultado.text = String("")
                self.resultado.hidden = true
                
                let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            
            } else {
            
                let texto: NSString? = NSString(data: data!, encoding: NSUTF8StringEncoding)!
                
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
                    
                    if json.count > 0 {
                        self.resultado.text = String(texto)
                        self.resultado.hidden = false
                        self.isbnEtiqueta.text = searchBar.text
                        
                    } else {
                        self.isbnEtiqueta.text = String("")
                        self.resultado.text = String("")
                        self.resultado.hidden = true
                        let alertController = UIAlertController(title: ":(", message: "No hubo resultados", preferredStyle: .Alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                    
                } catch {
                    
                    let alertController = UIAlertController(title: "Oops!", message: "Error serializing JSON: \(error)", preferredStyle: .Alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }

            }
           
            
            searchBar.resignFirstResponder()
            
            
        }
        
        dataTask.resume()
       
    
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    

    @IBAction func backgroundTap(sender: UIControl) {
        isbnBar.resignFirstResponder()
        resultado.resignFirstResponder()
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        
        isbnBar.text = String("")
    
        return true
    }
    
    


}

