//
//  CoreDataContextProvider.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//
import Foundation
import CoreData

protocol CoreDataContextProvider: AnyObject {
    
    var viewContext: NSManagedObjectContext { get }
    
    func performBackgroundTask( block: @escaping (_ writeContext: NSManagedObjectContext) -> Void,
                                receiveCompletionOn queue: DispatchQueue,
                                completion: (() -> Void)?)
}

final class CoreDataContextProviderImpl {
    
    // MARK: - Private properties
    
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private let containerName: String
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let managedObjectModelURL = Bundle.main.url(forResource: containerName, withExtension: "momd")!
        let managedObjectModel = NSManagedObjectModel(contentsOf: managedObjectModelURL)!
        let container = NSPersistentContainer(name: containerName, managedObjectModel: managedObjectModel)
        
        container.loadPersistentStores { _, error in
            if let error = error {
                print(error)
                fatalError("CoreData loadPersistentStored ended with error: \(error.localizedDescription)")
            }
        }
        
        // Включаем автоматическое слияние изменений между контекстами
        container.viewContext.automaticallyMergesChangesFromParent = true
        // Задаем политику разрешения конфликтов (преимущество у данных в памяти)
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }()
    
    // MARK: - Life cycle
    init(containerName: String = "ToDoList") {
        self.containerName = containerName
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - CoreDataContextProvider (implementation)
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func performBackgroundTask(
        block: @escaping (_ writeContext: NSManagedObjectContext) -> Void,
        receiveCompletionOn queue: DispatchQueue = .main,
        completion: (() -> Void)? = nil
    ) {
        operationQueue.addOperation() { [weak self] in
            let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
            context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
            context.persistentStoreCoordinator = self?.persistentContainer.persistentStoreCoordinator
            self?.observeChanges(in: context, completion: completion)
            
            context.performAndWait {
                block(context)
                context.saveOrRollback()
            }
        }
    }
}

// MARK: - Observe changes (private)
private extension CoreDataContextProviderImpl {
    func observeChanges( in context: NSManagedObjectContext,
                         receiveCompletionOn queue: DispatchQueue = .main,
                         completion: (() -> Void)? = nil) {
        NotificationCenter
            .default
            .addObserver(
                forName: .NSManagedObjectContextDidSave,
                object: context,
                queue: nil
            ) { [weak self] notification in
                self?.viewContext.perform {
                    self?.viewContext.mergeChanges(fromContextDidSave: notification)
                    queue.async {
                        completion?()
                    }
                }
            }
    }
}
