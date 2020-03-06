/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import HealthKit
import Foundation

class ProfileDataStore {
    
    class func getAgeSexAndBloodType() throws -> (age: Int,
        biologicalSex: HKBiologicalSex,
        bloodType: HKBloodType) {
            
            let healthKitStore = HKHealthStore()
            
            do {
                
                //1. This method throws an error if these data are not available.
                let birthdayComponents =  try healthKitStore.dateOfBirthComponents()
                let biologicalSex =       try healthKitStore.biologicalSex()
                let bloodType =           try healthKitStore.bloodType()
                
                //2. Use Calendar to calculate age.
                let today = Date()
                let calendar = Calendar.current
                let todayDateComponents = calendar.dateComponents([.year],
                                                                  from: today)
                let thisYear = todayDateComponents.year!
                let age = thisYear - birthdayComponents.year!
                
                //3. Unwrap the wrappers to get the underlying enum values.
                let unwrappedBiologicalSex = biologicalSex.biologicalSex
                let unwrappedBloodType = bloodType.bloodType
                
                return (age, unwrappedBiologicalSex, unwrappedBloodType)
            }
    }
    
    class func getMostRecentSample(for sampleType: HKSampleType,
                                   completion: @escaping (HKQuantitySample?, Error?) -> Swift.Void) {
        
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                            
                                            //2. Always dispatch to the main thread when complete.
                                            DispatchQueue.main.async {
                                                
                                                guard let samples = samples,
                                                    let mostRecentSample = samples.first as? HKQuantitySample else {
                                                        
                                                        completion(nil, error)
                                                        return
                                                }
                                                
                                                completion(mostRecentSample, nil)
                                                
                                            }
        }
        
        HKHealthStore().execute(sampleQuery)
    }
    
    class func getMostRecentHRSeriesSample(completion: @escaping (HKHeartbeatSeriesSample?, Error?) -> Swift.Void) {
        
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let limit = 1
        
        let sampleQuery = HKSampleQuery(sampleType: HKSeriesType.heartbeat(),
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                            
                                            //2. Always dispatch to the main thread when complete.
                                            DispatchQueue.main.async {
                                                
                                                guard let samples = samples,
                                                    let mostRecentSample = samples.first as? HKHeartbeatSeriesSample else {
                                                        
                                                        completion(nil, error)
                                                        return
                                                }
                                                
                                                completion(mostRecentSample, nil)
                                                
                                            }
        }
        
        HKHealthStore().execute(sampleQuery)
    }
    
    class func getSamples(for sampleType: HKSampleType,
                              completion: @escaping ([HKQuantitySample]?, Error?) -> Swift.Void) {
        
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let limit = 100
        
        let sampleQuery = HKSampleQuery(sampleType: sampleType,
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                            
                                            //2. Always dispatch to the main thread when complete.
                                            DispatchQueue.main.async {
                                                
                                                guard let samples = samples as? [HKQuantitySample] else {
                                                        
                                                        completion(nil, error)
                                                        return
                                                }
                                                
                                                completion(samples, nil)
                                                
                                            }
        }
        
        HKHealthStore().execute(sampleQuery)
    }
    
    class func getHRSeriesSamples(completion: @escaping ([HKHeartbeatSeriesSample]?, Error?) -> Swift.Void) {
        
        //1. Use HKQuery to load the most recent samples.
        let mostRecentPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast,
                                                              end: Date(),
                                                              options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate,
                                              ascending: false)
        
        let limit = 100
        
        let sampleQuery = HKSampleQuery(sampleType: HKSeriesType.heartbeat(),
                                        predicate: mostRecentPredicate,
                                        limit: limit,
                                        sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                                            
                                            //2. Always dispatch to the main thread when complete.
                                            DispatchQueue.main.async {
                                                
                                                guard let samples = samples as? [HKHeartbeatSeriesSample] else {
                                                        
                                                        completion(nil, error)
                                                        return
                                                }
                                                
                                                completion(samples, nil)
                                                
                                            }
        }
        
        HKHealthStore().execute(sampleQuery)
    }
    
    class func getBeatToBeatMeasurments(seriesSample: HKHeartbeatSeriesSample) {
        var semaphore = DispatchSemaphore (value: 0)
        var postParams = ""
        
        let hrseriesquery = HKHeartbeatSeriesQuery(heartbeatSeries: seriesSample) {
            (hrseriesquery, timeSinceSeriesStart, precededByGap, done, error) in
            
            guard error == nil else {
                //handle error
                return
            }
            // build our post JSON
            postParams = postParams + "{\"timeSinceSeriesStart\":\(timeSinceSeriesStart),\"precededByGap\":\(precededByGap)},"
            if (done){
                semaphore.signal() //query is finished, resume
            }
        }
        
        HKHealthStore().execute(hrseriesquery)
        
        semaphore.wait() // wait for query to finish
        
        let parameters = "[" + postParams.dropLast() + "]" //remove last , and add brackets for JSON array
        print("parameters", parameters)
        
        let postData = parameters.data(using: .utf8)
        
        //need to make url dynamic
        var request = URLRequest(url: URL(string: "http://192.168.0.8:3001/gethrv")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print(String(describing: error))
                return
            }
            print(String(data: data, encoding: .utf8)!) //shall I do something with the response?
            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait() //wait for REST call to finish
    }
    
    class func getMostRecentHeartRates() {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: .heartRate) else {
            print("HR Sample Type is no longer available in HealthKit")
            return
        }
        
        self.getSamples(for: sampleType) { (samples, error) in
            
            guard let samples = samples else {
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                return
            }
            
            for sample in samples {
                let heartRateSample = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                let timestamp = sample.endDate
                print("Heart rate sample: \(heartRateSample), Timestamp: \(timestamp)")
            }
            
        }
    }
    
    class func getMostRecentHRV() {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: .heartRateVariabilitySDNN) else {
            print("HR Sample Type is no longer available in HealthKit")
            return
        }
        
        self.getMostRecentSample(for: sampleType) { (sample, error) in
            
            guard let sample = sample else {
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                return
            }
            
            let hrvSample = sample
            print(hrvSample)
                        
        }
    }
    
    class func getMostRecentHRVSeriesSample() {

        self.getMostRecentHRSeriesSample() { (sample, error) in
        guard let sample = sample else {
            if let error = error {
                print(error.localizedDescription)
             }
                               
                return
            }
            
            getBeatToBeatMeasurments(seriesSample: sample)
            
            }
        
    }
    
    class func getMostRecentHRSeriesSamples() {
        self.getHRSeriesSamples() { (samples, error) in
            
            guard let samples = samples else {
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                return
            }
            
            for sample in samples {
                print(sample)
                getBeatToBeatMeasurments(seriesSample: sample)
//                let hrseriesquery = HKHeartbeatSeriesQuery(heartbeatSeries: sample) {
//                                     (hrseriesquery, timeSinceSeriesStart, precededByGap, done, error) in
//                                     guard error == nil else {
//                                         //handle error
//                                         return
//                                     }
//                                     // do stuff with time since series start
//                    print("Time since series start (ms): \(timeSinceSeriesStart * 1000) from sample \(sample.startDate)")
//
//                                 }
//                         HKHealthStore().execute(hrseriesquery)
               // print("RHR sample: \(heartRateSample), Timestamp: \(timestamp)")
            }
            
        }
    }
    
    class func getMostRecentRHRs() {
        guard let sampleType = HKSampleType.quantityType(forIdentifier: .restingHeartRate) else {
            print("HR Sample Type is no longer available in HealthKit")
            return
        }
        
        self.getSamples(for: sampleType) { (samples, error) in
            
            guard let samples = samples else {
                
                if let error = error {
                    print(error.localizedDescription)
                }
                
                return
            }
            
            for sample in samples {
                let heartRateSample = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                let timestamp = sample.endDate
                //print("RHR sample: \(heartRateSample), Timestamp: \(timestamp)")
            }
            
        }
    }
    
    
    
    class func saveBodyMassIndexSample(bodyMassIndex: Double, date: Date) {
        
        //1.  Make sure the body mass type exists
        guard let bodyMassIndexType = HKQuantityType.quantityType(forIdentifier: .bodyMassIndex) else {
            fatalError("Body Mass Index Type is no longer available in HealthKit")
        }
        
        //2.  Use the Count HKUnit to create a body mass quantity
        let bodyMassQuantity = HKQuantity(unit: HKUnit.count(),
                                          doubleValue: bodyMassIndex)
        
        let bodyMassIndexSample = HKQuantitySample(type: bodyMassIndexType,
                                                   quantity: bodyMassQuantity,
                                                   start: date,
                                                   end: date)
        
        //3.  Save the same to HealthKit
        HKHealthStore().save(bodyMassIndexSample) { (success, error) in
            
            if let error = error {
                print("Error Saving BMI Sample: \(error.localizedDescription)")
            } else {
                print("Successfully saved BMI Sample")
            }
        }
        
    }
}

