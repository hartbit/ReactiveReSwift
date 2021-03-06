//
//  Middleware.swift
//  FPExamples
//
//  Created by Charlotte Tortorella on 25/11/16.
//  Copyright © 2016 Charlotte Tortorella. All rights reserved.
//

/**
 Middleware is a structure that allows you to modify, filter out and dispatch more
 actions, before the action being handled reaches the store.
 */
public struct Middleware<State: StateType> {
    public typealias DispatchFunction = (Action) -> Void
    public typealias GetState = () -> State

    private let transform: (GetState, DispatchFunction, Action) -> Action?

    /// Create a blank slate Middleware.
    public init() {
        self.transform = { $2 }
    }

    /**
     Initialises the middleware with a transformative function.
     
     - parameter transform: The function that will be able to modify passed actions.
     */
    internal init(_ transform: @escaping (GetState, DispatchFunction, Action) -> Action?) {
        self.transform = transform
    }

    /**
     Initialises the middleware by concatenating the transformative functions from
     the middleware that was passed in.
     */
    public init(_ first: Middleware<State>, _ rest: Middleware<State>...) {
        self = rest.reduce(first) {
            $0.concat($1)
        }
    }

    /// Runs the underlying function of the middleware and returns the result.
    internal func run(state: GetState, dispatch: DispatchFunction, argument: Action) -> Action? {
        return transform(state, dispatch, argument)
    }

    /// Safe encapsulation of side effects guaranteed not to affect the action being passed through the middleware.
    public func sideEffect(_ effect: @escaping (GetState, DispatchFunction, Action) -> Void) -> Middleware<State> {
        return Middleware<State> {
            guard let action = self.transform($0, $1, $2) else { return nil }
            effect($0, $1, action)
            return action
        }
    }

    /// Concatenates the transform function of the passed `Middleware` onto the callee's transform.
    public func concat(_ other: Middleware<State>) -> Middleware<State> {
        return Middleware<State> {
            guard let action = self.transform($0, $1, $2) else { return nil }
            return other.transform($0, $1, action)
        }
    }

    /// Concatenates the transform function onto the callee's transform.
    public func map(_ transform: @escaping (GetState, Action) -> Action) -> Middleware<State> {
        return flatMap(transform)
    }

    /// Concatenates the transform function onto the callee's transform.
    public func flatMap(_ transform: @escaping (GetState, Action) -> Action?) -> Middleware<State> {
        return Middleware<State> {
            guard let action = self.transform($0, $1, $2) else { return nil }
            return transform($0, action)
        }
    }

    /// Drop the Action if `predicate(action) != true`.
    public func filter(_ predicate: @escaping (GetState, Action) -> Bool) -> Middleware<State> {
        return Middleware<State> {
            guard let action = self.transform($0, $1, $2), predicate($0, action) else { return nil }
            return action
        }
    }
}
