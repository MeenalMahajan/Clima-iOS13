//
//  WeatherManager.swift
//  Clima
//
//  Created by Apple on 26/04/24.
//  Copyright © 2024 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager : WeatherManager, weather : WeatherModel)
    func didFailWithError(error : Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=1c80dcfc77562b73277d8bcd84b6d476&units=metric"
    
    
    var delegate : WeatherManagerDelegate?
    
    func fetchWeather(cityName: String){
        
        let urlString = "\(weatherURL)&q=\(cityName)"
        
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
        
    }
    
            // with = extrenal parameter urlString = internal parameter
    func performRequest(with urlString: String){
        
        //Step-1 Create a URL
        if let url = URL(string: urlString){
            
            //Step-2 Create a URLSession
            let session = URLSession(configuration: .default)
            
            //Step-3 Give URL Session a Task
            
            let task = session.dataTask(with: url) { data, response, error in // closure
                
                if error != nil{
                    
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data{
                    
                    if let weather = self.parseJSON(safeData){
                        
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                    
                }
                
            }
            
            //Start the Task
            task.resume()
        }
    }
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        
        let decoder = JSONDecoder()
      
        do{
          let decodedData =  try decoder.decode(WeatherData.self, from: weatherData)
            
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            
            return weather
            //print(weather.temperatureString)
         
            
        } catch{
           
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    
    }
    
  
}
