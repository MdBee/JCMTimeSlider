//
//  IterisAPI.swift
//  IterisPoC
//
//  Created by Juan C. Mendez on 3/26/15.
//  Copyright (c) 2015 Accenture. All rights reserved.
//

import Foundation

@objc public protocol IterisAPIDelegate {
  func didLoadIterisLayers(layers:NSArray)
}

@objc public class IterisLayerKind {
  let name: String;
  let code: String;
  
  init(name n: String, code c: String) {
    name = n
    code = c
  }
}

public let iterisLayers = [
  IterisLayerKind(name:"Air Temperature", code:"air_temp"),
  IterisLayerKind(name:"Max Air Temp, last 24 hrs", code:"air_temp_max_last_24hr"),
  IterisLayerKind(name:"Min Air Temp, last 24 hrs", code:"air_temp_min_last_24hr"),
  IterisLayerKind(name:"Dew Point", code:"dew_point"),
  IterisLayerKind(name:"Hail", code:"hail"),
  IterisLayerKind(name:"Hail, last 24 hrs", code:"hail_last_24hr"),
  IterisLayerKind(name:"Precipitation, 1hr", code:"precip_acc_1hr"),
  IterisLayerKind(name:"Precipitation, last 24 hrs", code:"precip_acc_last_24hr"),
  IterisLayerKind(name:"Precipitation, next 24 hrs", code:"precip_acc_next_24hr"),
  IterisLayerKind(name:"Precipitation, likelihood, next 24 hrs", code:"precip_prob_next_24hr"),
  IterisLayerKind(name:"Radar", code:"radar"),
  IterisLayerKind(name:"Radar with Forecast", code:"radar_with_forecast"),
  IterisLayerKind(name:"Radar with Metrad Plus", code:"radar_with_metrad_plus"),
  IterisLayerKind(name:"Relative Humidity", code:"relative_humidity"),
  IterisLayerKind(name:"Satellite Infrared", code:"satellite_infrared"),
  IterisLayerKind(name:"Satellite Visible", code:"satellite_visible"),
  IterisLayerKind(name:"Satellite Water Vapor", code:"satellite_watervapor"),
  IterisLayerKind(name:"Snow, 1hr", code:"snow_acc_1hr"),
  IterisLayerKind(name:"Snow, last 24 hrs", code:"snow_acc_last_24hr"),
  IterisLayerKind(name:"Snow, next 24 hrs", code:"snow_acc_next_24hr"),
  IterisLayerKind(name:"Visibility", code:"visibility"),
  IterisLayerKind(name:"Min Visibility, next 24hr", code:"visibility_min_next_24hr"),
  IterisLayerKind(name:"Wind Gusts", code:"wind_gusts"),
  IterisLayerKind(name:"Wind Speed", code:"wind_speed"),
  IterisLayerKind(name:"Max Wind Speed, next 24hr", code:"wind_speed_max_next_24hr")
]

public enum DataType: String {
  case AirTemp￼￼ = "air_temp"
  case AirTempMaxLast24hr = "air_temp_max_last_24hr"
  case AirTempMinLast24hr = "air_temp_min_last_24hr"
  case DewPoint = "dew_point"
  case Hail = "hail"
  case HailLast24hr = "hail_last_24hr"
  case PrecipAcc1hr = "precip_acc_1hr"
  case PrecipAccLast24hr = "precip_acc_last_24hr"
  case PrecipAccNext24hr = "precip_acc_next_24hr"
  case PrecipProbNext24hr = "precip_prob_next_24hr"
//  case PrecipStartTimeCST5CDT = "precip_start_time_cst6cdt"
//  case PrecipStartTimeEST5EDT = "precip_start_time_est5edt"
//  case PrecipStartTimeMST7MDT = "precip_start_time_mst7mdt"
  case Radar = "radar"
  case RadarWithForecast = "radar_with_forecast"
  case RadarWithMetradPlus = "radar_with_metrad_plus"
  case RelativeHumidity = "relative_humidity"
  case SatelliteInfrared = "satellite_infrared"
  case SatelliteVisible = "satellite_visible"
  case SatelliteWatervapor = "satellite_watervapor"
  case SnowAcc1hr = "snow_acc_1hr"
  case SnowAccLast24hr = "snow_acc_last_24hr"
  case SnowAccNext24hr = "snow_acc_next_24hr"
  case Visibility = "visibility"  //documentation says "Visibility" but that returns no data
  case VisibilityMinNext24hr = "visibility_min_next_24hr"
  case WindGusts = "wind_gusts"
  case WindSpeed = "wind_speed"
  case WindSpeedMaxNext24hr = "wind_speed_max_next_24hr"
}

/**
This class abstracts the interaction with the Iteris API.
*/
@objc class IterisAPI {
  
  var delegate: IterisAPIDelegate?

  // We want this class to be a singleton.  We chose the nested struct pattern shown
  // at https://github.com/hpique/SwiftSingleton because we may not have Swift 1.2
  
  class var sharedInstance: IterisAPI {
    struct Static {
      static let instance : IterisAPI = IterisAPI()
    }
    return Static.instance
  }
  
  private var app_id:String { get {
//    let keys = PagpocKeys()
//    return keys.iterisAppId()
    return "<iterisAppId goes here>"
    }}
  
  private var app_key:String { get {
//    let keys = PagpocKeys()
//    return keys.iterisAppKey()
    return "<iterisAppKey goes here>"
    }}
  
  private let url_base = "https://ag.clearpathapis.com/v1.1"
  private let tiles_url_base = "http://tiles.ag.clearpathapis.com/v1.0"

  /**
  Constructs the URL required to query the API for current conditions at a coordinate
  
  :param: lat latitude element of the coordinate
  :param: lon longitude element of the coordinate
  
  :returns: string needed for the GET call to the API
  */
  func currentConditionsURL(lat:Double, lon:Double) -> String {
    return "\(url_base)/currentconditions?app_id=\(app_id)&app_key=\(app_key)&location=\(lat),\(lon)"
  }
  
  func historicDailyURL(lat:Double, lon:Double, startDate:NSDate, endDate:NSDate) -> String {
    
    let isoStart = UInt64(floor(startDate.timeIntervalSince1970))
    let isoEnd = UInt64(floor(endDate.timeIntervalSince1970))
    
    return "\(url_base)/historical/daily?app_id=\(app_id)&app_key=\(app_key)&start=\(isoStart)&end=\(isoEnd)&location=\(lat),\(lon)"
  }
    
  func dailyForecastURL(lat:Double, lon:Double, startDate:Int, endDate:Int) -> String {
        
    return "\(url_base)/forecast/daily?app_id=\(app_id)&app_key=\(app_key)&start=\(startDate)&end=\(endDate)&location=\(lat),\(lon)"
  }
  
  
  // MARK: Weather Map Support Methods
  
  func layerURL(dataType:String, startDate:NSDate, endDate:NSDate, displayInterval:Int = 1200, displayRange:Int = 1) -> String {
    
    assert(validateDataType(dataType),"invalid dataType for layerURL")
    
    let isoStart = UInt64(floor(startDate.timeIntervalSince1970))
    
    return "\(tiles_url_base)/layer_index?app_id=\(app_id)&app_key=\(app_key)&display_start=\(isoStart)&display_range=\(displayRange)&display_interval=\(displayInterval)&layer_filter=\(dataType)"
  }
  
 
  func tileURLStringWithAuthParams(tileURL:String) ->NSString {
    
    return "\(tileURL){z}/{x}/{y}.png?app_id=\(app_id)&app_key=\(app_key)"
  }

  
  func validateDataType(dataType:String) -> Bool {
    if DataType(rawValue: dataType) != nil {
      return true
    }
    return false
  }
  
  var data = NSMutableData()
  
  func getLayers() {
    let internetURL = NSURL(string:"http://ag.clearpathapis.com/v1.0/layer_index?app_id=\(app_id)&app_key=\(app_key)")
    let siteURL = NSURLRequest(URL: internetURL!)
    let siteData = NSURLConnection(request: siteURL, delegate: self, startImmediately: true)
  }
  
  func connection(connection: NSURLConnection!, didReceiveData _data: NSData!)
  {
    self.data.appendData(_data)
  }
  
  
  func iterisLayerKindWithCode(code: NSString) -> IterisLayerKind? {
    
    for layer in iterisLayers {
      if (layer.code == code) {
        return layer
      }
    }
    return nil
  }
  
  func connectionDidFinishLoading(connection: NSURLConnection!)
  {
    var jsonStr = NSString(data:self.data, encoding:NSUTF8StringEncoding)
    var data = jsonStr!.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: false)
    var localError: NSError?
    var json: AnyObject! = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &localError)
    if let dict = json as? [String: AnyObject] {
      if let displayIntervals = dict["display_intervals"] as? NSArray {
        if let displayInterval0 = displayIntervals[0] as? NSDictionary {
          if let layers = displayInterval0["layers"] as? NSDictionary {
            if let contigus = layers.valueForKey("contigus") as? NSDictionary {
              let dataTypes = contigus.allKeys

              // Sort data types 
              var iterisLayerKindArray = [IterisLayerKind]()
              
              var iterisLayer: IterisLayerKind?
              
              for layerCode in dataTypes {
                iterisLayer = iterisLayerKindWithCode(layerCode as! NSString)
                if (iterisLayer != nil) {
                  iterisLayerKindArray.append(iterisLayer!)
//                  iterisLayerKindArray.addObject(iterisLayer as! AnyObject)
                }
              }
              
              iterisLayerKindArray.sort({ $0.code < $1.code })  // sort in ASC order by layer code
              
              // Inform delegate that we loaded Iteris layers
              delegate?.didLoadIterisLayers(iterisLayerKindArray)
            }
          }
        }
      }
    }
  }
}
