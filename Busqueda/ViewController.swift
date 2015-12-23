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
    @IBOutlet weak var tituloEtiqueta: UILabel!
    @IBOutlet weak var tituloValor: UILabel!
    @IBOutlet weak var autoresEtiqueta: UILabel!
    @IBOutlet weak var autoresValor: UILabel!
    @IBOutlet weak var portadaEtiqueta: UILabel!
    @IBOutlet weak var portadaImagen: UIImageView!
    let urlString : String = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isbnBar.delegate = self
        tituloEtiqueta.hidden = true
        tituloValor.hidden = true
        autoresEtiqueta.hidden = true
        autoresValor.hidden = true
        portadaEtiqueta.hidden = true
        portadaImagen.hidden = true

        
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
                
                self.resetValues()
                
                let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .Alert)
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                self.presentViewController(alertController, animated: true, completion: nil)
                
            
            } else {
            
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableLeaves)
                  
                    if json.count > 0 {

                        let root = json as! NSDictionary
                        let firstItem = root["ISBN:"+searchBar.text!] as! NSDictionary
                        let title = firstItem["title"] as! NSString as String
                        self.tituloValor.text = title
                       
                        //Codigo de referencia http://stackoverflow.com/questions/24231680/loading-image-from-url
                        //print("Begin of code")
                        if let checkedUrl = NSURL(string: "http://covers.openlibrary.org/b/isbn/" + searchBar.text! + ".jpg") {
                            self.portadaImagen.contentMode = .ScaleAspectFit
                            self.downloadImage(checkedUrl)
                        }
                        //print("End of code. The image will continue downloading in the background and it will be loaded when it ends.")
                        
                        let authors = firstItem["authors"] as! [[String: String]]
                        var authorsArray : [String] = []
                        
                        if authors.count > 0 {
                            
                            for(_, element) in authors.enumerate() {
                                let name = element["name"]
                                authorsArray.append(name!)
                                
                            }
                            
                            self.autoresValor.text = authorsArray.joinWithSeparator(",")
                            self.autoresValor.sizeToFit()
                            
                        }
                        
                         self.showValues()
                        
                        
                    } else {
                        self.resetValues()
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

    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        
        isbnBar.text = String("")
    
        return true
    }
    
    func resetValues() {
        
        self.tituloEtiqueta.hidden = true
        self.tituloValor.hidden = true
        self.autoresEtiqueta.hidden = true
        self.autoresValor.hidden = true
        self.portadaEtiqueta.hidden = true
        self.portadaImagen.hidden = true
        
        
        self.tituloValor.text = String("")
        self.autoresValor.text = String("")
        self.portadaImagen.image = nil
    }
    
    func showValues() {
        
        self.tituloEtiqueta.hidden = false
        self.tituloValor.hidden = false
        self.autoresEtiqueta.hidden = false
        self.autoresValor.hidden = false
        self.portadaEtiqueta.hidden = false
        self.portadaImagen.hidden = false

    }
    
    /* Funciones de referencia tomadas de http://stackoverflow.com/questions/24231680/loading-image-from-url */
    
    func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL){
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                self.portadaImagen.image = UIImage(data: data)
            }
        }
    }
    
    


}

