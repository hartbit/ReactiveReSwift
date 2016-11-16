//
//  ObservableStoreType.swift
//  ReSwift
//
//  Created by Charlotte Tortorella on 11/17/16.
//  Copyright © 2016 Benjamin Encz. All rights reserved.
//

import Foundation

/**
 Defines the interface of Stores in ReSwift. `Store` is the default implementation of this
 interface. Applications have a single store that stores the entire application state.
 Stores receive actions and use reducers combined with these actions, to calculate state changes.
 Upon every state update a store informs all of its subscribers.
 */
public protocol ObservableStoreType {

    associatedtype ObservableProperty: ObservablePropertyType
    associatedtype State: StateType
    
    /// Initializes the store with a reducer and an intial state.
    init(reducer: AnyObservableReducer, stateType: State.Type, observable: ObservableProperty)

    /// Initializes the store with a reducer, an initial state and a list of middleware.
    /// Middleware is applied in the order in which it is passed into this constructor.
    init(reducer: AnyObservableReducer, stateType: State.Type, observable: ObservableProperty, middleware: [Middleware])

    /// The observable of values stored in the store.
    var observable: ObservableProperty! { get }

    /**
     The main dispatch function that is used by all convenience `dispatch` methods.
     This dispatch function can be extended by providing middlewares.
     */
    var dispatchFunction: DispatchFunction! { get }

    /**
     Dispatches an action. This is the simplest way to modify the stores state.

     Example of dispatching an action:

     ```
     store.dispatch( CounterAction.IncreaseCounter )
     ```

     - parameter action: The action that is being dispatched to the store
     - returns: By default returns the dispatched action, but middlewares can change the
     return type, e.g. to return promises
     */
    func dispatch(_ action: Action) -> Any

    /**
     Dispatches an action creator to the store. Action creators are functions that generate
     actions. They are called by the store and receive the current state of the application
     and a reference to the store as their input.

     Based on that input the action creator can either return an action or not. Alternatively
     the action creator can also perform an asynchronous operation and dispatch a new action
     at the end of it.

     Example of an action creator:

     ```
     func deleteNote(noteID: Int) -> ActionCreator {
        return { state, store in
            // only delete note if editing is enabled
            if (state.editingEnabled == true) {
                return NoteDataAction.DeleteNote(noteID)
            } else {
                return nil
            }
        }
     }
     ```

     This action creator can then be dispatched as following:

     ```
     store.dispatch( noteActionCreatore.deleteNote(3) )
     ```

     - returns: By default returns the dispatched action, but middlewares can change the
     return type, e.g. to return promises
     */
    func dispatch(_ actionCreator: ActionCreator) -> Any

    /**
     Dispatches an async action creator to the store. An async action creator generates an
     action creator asynchronously.
     */
    func dispatch(_ asyncActionCreator: AsyncActionCreator)

    /**
     Dispatches an async action creator to the store. An async action creator generates an
     action creator asynchronously. Use this method if you want to wait for the state change
     triggered by the asynchronously generated action creator.

     This overloaded version of `dispatch` calls the provided `callback` as soon as the
     asynchronoously dispatched action has caused a new state calculation.

     - Note: If the ActionCreator does not dispatch an action, the callback block will never
     be called
     */
    func dispatch(_ asyncActionCreator: AsyncActionCreator, callback: DispatchCallback?)


    /**
     An optional callback that can be passed to the `dispatch` method.
     This callback will be called when the dispatched action triggers a new state calculation.
     This is useful when you need to wait on a state change, triggered by an action (e.g. wait on
     a successful login). However, you should try to use this callback very seldom as it
     deviates slighlty from the unidirectional data flow principal.
     */
    associatedtype DispatchCallback = (State) -> Void

    /**
     An ActionCreator is a function that, based on the received state argument, might or might not
     create an action.

     Example:

     ```
     func deleteNote(noteID: Int) -> ActionCreator {
        return { state, store in
            // only delete note if editing is enabled
            if (state.editingEnabled == true) {
                return NoteDataAction.DeleteNote(noteID)
            } else {
                return nil
            }
        }
     }
     ```

     */
    associatedtype ActionCreator = (_ state: State, _ store: ObservableStoreType) -> Action?

    /// AsyncActionCreators allow the developer to wait for the completion of an async action.
    associatedtype AsyncActionCreator =
        (_ state: State, _ store: ObservableStoreType,
         _ actionCreatorCallback: (ActionCreator) -> Void) -> Void
}
