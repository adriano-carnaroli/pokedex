//
//  CoreDataPersistenceManager.swift
//  Pokedex
//
//  Created by Adriano Carnaroli on 17/12/20.
//

import Foundation
import CoreData

enum CoreDataPersistenceError: Error{
    case notFound(reason: String)
}

class CoreDataPersistenceManager{
    
    private func getCoreDataDescription(name:String)->NSEntityDescription?{
        return NSEntityDescription.entity(forEntityName: name, in: self.context())
    }
    
    func createCoreDataObject(name:String) throws ->NSManagedObject{
        guard let _ = getCoreDataDescription(name:name) else {
            throw CoreDataPersistenceError.notFound(reason: "Name class \(name), not found in coredata file")
        }
        return NSEntityDescription.insertNewObject(forEntityName: name, into: self.context())
    }
    
    func updateObject<T>(fieldId:String, valueId:Any, object:T) throws {
        
        let result = try getCoredataObjects(fieldValues: [fieldId:valueId], object: type(of:object.self))
        if let first = result.first as? NSManagedObject {
            _ = updateManagedObject(from: object, to: first)
        }
        
        saveContext()
    }
    
    func saveObject<T>(object:T) throws{
        
        var mainCoreDataObject = try createCoreDataObject(name: getCoredataClassName(object: type(of:object.self)))
        mainCoreDataObject = updateManagedObject(from: object, to: mainCoreDataObject)
        saveContext()
    }
    
    func getObject<T:Codable>(fieldValues:[String:Any], object:T.Type = T.self)->[T]{
        var objects:Array<T> = []
        do {
            let result = try getCoredataObjects(fieldValues: fieldValues, object:object)
            objects = try convertTo(fromFetch: result, to: object)
        } catch {
            print(self, error)
        }
        return objects
    }
    
    func getAllObject<T:Decodable>(object:T.Type = T.self)->[T]?{
        var array = Array<T>()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: getCoredataClassName(object: object))
        request.returnsObjectsAsFaults = false
        do {
            let result = try context().fetch(request)
            array = try convertTo(fromFetch: result, to: object)
        } catch {
            print(self,error)
        }
        return array
    }
    
    func removeAllObjects<T>(object:T.Type = T.self) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: getCoredataClassName(object: object))
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context().execute(deleteRequest)
        saveContext()
    }
    
    func removeObject<T>(fieldID:String, valueID:Any, object:T.Type = T.self) throws{
        let objects = try getCoredataObjects(fieldValues:[fieldID : valueID ], object:object)
        for object in objects{
            context().delete(object as! NSManagedObject)
        }
        saveContext()
    }
    
    func removeObject<T>(fieldID:String, valueID:Any, secondFieldID:String, secondValueID:Any, object:T.Type = T.self) throws{
        let objects = try getCoredataObjects(fieldValues:[fieldID : valueID, secondFieldID : secondValueID ], object:object)
        for object in objects{
            context().delete(object as! NSManagedObject)
        }
    }
    
    func removeObject<T>(fieldID:String, valueID:Any, secondFieldID:String, secondValueID:Any, thirdFieldID:String, thirdValueID:Any, object:T.Type = T.self) throws{
        let objects = try getCoredataObjects(fieldValues:[fieldID : valueID, secondFieldID : secondValueID, thirdFieldID : thirdValueID ], object:object)
        for object in objects{
            context().delete(object as! NSManagedObject)
        }
    }
    
    func deleteAllData(_ entity:String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context().fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                context().delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
    //MARK: Coredata Custom Methods
    func getObjectWithMaxId<T:Decodable>(object:T.Type = T.self, fieldKey:String) ->[T]? {
        var array = Array<T>()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: getCoredataClassName(object: object))
        let idDescriptor: NSSortDescriptor = NSSortDescriptor(key: fieldKey, ascending: false)
        fetchRequest.sortDescriptors = [idDescriptor]
        fetchRequest.fetchLimit = 1
        do {
            let results = try context().fetch(fetchRequest)
            array = try convertTo(fromFetch: results, to: object)
        } catch {
            let fetchError = error as NSError
            print(self, fetchError)
        }
        return array
    }
    
    private func saveContext(){
        CoreDataService.shared.saveContext()
    }
    
    private func context()->NSManagedObjectContext{
        return CoreDataService.shared.persistentContainer.viewContext
    }
    
    private func getCoredataObjects<T>(fieldValues:[String:Any],object:T.Type = T.self)throws ->[Any]{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: getCoredataClassName(object: object))
        
        var predicates = [NSPredicate]()
        for (key, value) in fieldValues {
            var predicate:NSPredicate?
            if value is Int {
                predicate = NSPredicate(format: "%K = %d", key, value as! CVarArg)
            } else if value is Int16 {
                predicate = NSPredicate(format: "%K = %d", key, value as! CVarArg)
            } else if value is Double {
                predicate = NSPredicate(format: "%K = %f", key, value as! CVarArg)
            } else if value is Bool {
                predicate = NSPredicate(format: "%K = %d", key, value as! CVarArg)
            } else {
                predicate = NSPredicate(format: "%K = %@", key, value as! CVarArg)
            }
            
            predicates.append(predicate!)
        }
        
        request.predicate = NSCompoundPredicate.init(andPredicateWithSubpredicates: predicates)
        request.returnsObjectsAsFaults = false
        
        return try context().fetch(request)
    }
    
    private func updateManagedObject<T>(from object:T, to coredataObject:NSManagedObject)->NSManagedObject{
        let objectMirror = Mirror(reflecting: object)
        for (name, value) in objectMirror.children {
            guard let name = name else { continue }
            var managedValue = value
            print("Save object -> \(name): \(type(of: managedValue)) = '\(value)'")
            
            let description = String(describing: type(of: managedValue))
            
            //propriedade desconhecida de uma struct
            if name.contains("some"){
                continue
            }
            
            if description == "Optional<Data>" {
                if (managedValue as? Data == nil) { continue }
            }
            
            if description == "Optional<Bool>" {
                if (managedValue as? Bool == nil) { managedValue = false}
            }
            
            if description == "Optional<String>" {
                if (managedValue as? String == nil) { continue}
            }
            
            if description.hasPrefix("Optional<Array<") || description.hasPrefix("Array<") {
                continue
                //melhorar aqui
                //let array:Array? = value as? Array<Any>
                //guard array != nil else {continue}
            }
            
            let elements = ["Bool", "Int", "String", "Double", "Data", "Date"]
            
            let filteredElements = elements.filter({(item: String) -> Bool in
                let stringMatch = description.lowercased().contains(item.lowercased())
                return stringMatch
            })
            
            if filteredElements.count == 0{
                var className = getCoredataClassName(object: type(of: managedValue))
                className = className.replacingOccurrences(of: "Optional<", with: "").replacingOccurrences(of: ">", with: "")
                do{
                    let managedObject = try createCoreDataObject(name: className)
                    managedValue = updateManagedObject(from: value, to: managedObject)
                }catch{
                    print(self,error)
                    continue
                }
            }
            
            coredataObject.setValue(managedValue, forKey: name)
        }
        return coredataObject
    }
    
    private func convertTo<T:Decodable>(fromFetch fetchResult:[Any], to type:T.Type = T.self)throws ->[T]{
        var array:Array<T> = []
        for coreDataObject in fetchResult as! [NSManagedObject] {
            var properties = [String:Any]()
            for (name, description) in  coreDataObject.entity.attributesByName {
                if description.attributeType == .booleanAttributeType {
                    /* Tratamento para converter o NSNumber usado como Bool no coredata para simplemenste Bool
                     * Esse tratamento é necessário por causa do Decoder do Codable que não reconhece o NSNumber
                     * e gera um erro do tipo Mismatch */
                    let value = coreDataObject.value(forKey: name) ?? false
                    properties[name] = (value as! NSNumber).boolValue
                    
                } else if description.attributeType == .dateAttributeType {
                    /* Tratamento para converter o NSDate do coredata para simplemenste uma string,
                     * Esse tratamento é necessário por causa do JSONSerialization, que não reconhece o tipo NSDate/Date
                     * e gera um erro do tipo 'JSONSerialization Invalid type in JSON write (_SwiftValue)' */
                    let value = coreDataObject.value(forKey: name) ?? Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
                    properties[name] = formatter.string(from: value as! Date)
                } else if (description.attributeType == .binaryDataAttributeType){
                    /* Convertendo o NSData/Data para base64 para ser possível converter para JSON
                     * ao realizar o decode com o Decoder, automaticamente ele irá converte para aquilo que representa */
                    
                    if let value = coreDataObject.value(forKey: name) as? Data {
                        properties[name] = value.base64EncodedString()
                    }
                } else if (description.attributeType == .objectIDAttributeType){
                    
                } else {
                    properties[name] = coreDataObject.value(forKey: name)
                }
            }
            
            let jsonData = properties.jsonData
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
            let other:T =  try decoder.decode(T.self, from:jsonData!)
            array.append(other)
        }
        return array
    }
    
    private func getCoredataClassName<T>(object:T)->String{
        return String(describing:object)+"DAO"
    }
}

extension DateFormatter {
    fileprivate static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension Dictionary {
    fileprivate var jsonData: Data? {
        
        do {
            let theJSONData = try JSONSerialization.data(withJSONObject: self,
                                                         options: [])
            return theJSONData
        } catch  {
            print(self, error)
            return nil
        }
    }
}

// MARK: - Core Data stack
fileprivate final class CoreDataService {
    
    static var shared:CoreDataService = CoreDataService()
    
    private init(){}
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Pokedex")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
