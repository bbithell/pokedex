//
//  Pokemon.swift
//  pokedex
//
//  Created by Bill Bithell on 6/21/16.
//  Copyright © 2016 Bill Bithell. All rights reserved.
//

import Foundation
import Alamofire

class Pokemon {
    
    private var _name: String!
    private var _pokedexId: Int!
    private var _description: String!
    private var _type: String!
    private var _defense: String!
    private var _height: String!
    private var _weight: String!
    private var _attack: String!
    private var _nextEvolutionTxt: String!
    private var _nextEvolutionId: String!
    private var _nextEvolutionLevel: String!
    private var _pokemonUrl: String!
    
    var name: String {
        get {
            if _name == nil {
                _name = ""
            }
            return _name
        }
    }
    
    var pokedexId: Int {

        return _pokedexId
    }
    
    var description: String {
        get {
            if _description == nil {
                _description = ""
            }
            return _description
        }
    }
    
    var type: String {
        get {
            if _type == nil {
                _type = ""
            }
            return _type
        }
    }
    
    var defense: String {
        get {
            if _defense == nil {
                _defense = ""
            }
            return _defense
        }
    }
    
    var height: String {
        get {
            if _height == nil {
               _height = ""
            }
            return _height
        }
    }
    
    var weight: String {
        get {
            if _weight == nil {
                _weight = ""
            }
            return _weight
        }
    }
    
    var attack: String {
        get {
            if _attack == nil {
                _attack = ""
            }
            return _attack
        }
    }
    
    var nextEvolutionTxt: String {
        get {
            if _nextEvolutionTxt == nil {
                _nextEvolutionTxt = ""
            }
            return _nextEvolutionTxt
        }
    }
    
    var nextEvolutionId: String {
        get {
            if _nextEvolutionId == nil {
                _nextEvolutionId = ""
            }
            return _nextEvolutionId
        }
    }
    
    var nextEvolutionLevel: String {
        get {
            if _nextEvolutionLevel == nil {
                _nextEvolutionLevel = ""
            }
            return _nextEvolutionLevel
        }
    }
    
    init(name: String, pokedexId: Int) {
        self._name = name
        self._pokedexId = pokedexId
        
        _pokemonUrl = "\(URL_BASE)\(URL_POKEMON)\(self._pokedexId)/"
    }
    
    func downloadPokemonDetails(completed: DownloadComplete) {
        
        let url = NSURL(string: _pokemonUrl)
        Alamofire.request(.GET, url!).responseJSON { response in
            let result = response.result
            
            if let dict = result.value as? Dictionary<String, AnyObject> {
                if let weight = dict["weight"] as? String {
                    self._weight = weight
                }
                
                if let height = dict["height"] as? String {
                    self._height = height
                }
                
                if let attack = dict["attack"] as? Int {
                    self._attack = "\(attack)"
                }
                
                if let defense = dict["defense"] as? Int {
                    self._defense = "\(defense)"
                }
                
                // Get Type
                if let types = dict["types"] as? [Dictionary<String, String>] where types.count > 0 {
                    if let typeName = types[0]["name"] {
                        self._type = typeName.capitalizedString
                    }
                    
                    if types.count > 1 {
                        for var x = 1; x < types.count; x++ {
                            if let typeName = types[x]["name"] {
                                self._type! += "/\(typeName.capitalizedString)"
                            }
                        }
                    }
                } else {
                    self._type = ""
                }
                
                // Get description
                if let descArr = dict["descriptions"] as? [Dictionary<String, String>] where descArr.count > 0 {
                    if let url = descArr[0]["resource_uri"] {
                        let nsurl = NSURL(string: "\(URL_BASE)\(url)")!
                        Alamofire.request(.GET, nsurl).responseJSON { response in
                            
                            let desResult = response.result
                            if let descDict = desResult.value as? Dictionary<String, AnyObject> {
                                
                                if let description = descDict["description"] as? String {
                                    self._description = description
                                    
                                }
                            }
                            
                            completed()
                        }
                        
                    }
                } else {
                    self._description = ""
                }
                
                // get evolution
                if let evolutions = dict["evolutions"] as? [Dictionary<String, AnyObject>] where evolutions.count > 0 {
                    
                    if let to = evolutions[0]["to"] as? String {
                        
                        // continue if mega is not found in to name
                        if to.rangeOfString("mega") == nil {
                            
                            if let uri = evolutions[0]["resource_uri"] as? String {
                                
                                let newStr = uri.stringByReplacingOccurrencesOfString("/api/vi/pokemon/", withString: "")
                                let pId = newStr.stringByReplacingOccurrencesOfString("/", withString: "")
                                
                                self._nextEvolutionId = pId
                                self._nextEvolutionTxt = to
                                
                                if let level = evolutions[0]["level"] as? Int {
                                    self._nextEvolutionLevel = "\(level)"
                                }
                                
                            }
                            
                        }
                    }
                }
            }
        }
    }
}


