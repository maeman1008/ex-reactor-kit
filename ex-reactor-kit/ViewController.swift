







import UIKit

import RxCocoa
import RxSwift

class ViewController: UIViewController, StoryboardView {
    @IBOutlet var decreaseButton: UIButton!
    @IBOutlet var increaseButton: UIButton!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    var disposeBag = DisposeBag()
    var reactor: CounterViewReactor? = CounterViewReactor()
    func bind(reactor: CounterViewReactor) {
        
        increaseButton.rx.tap
            .map { Reactor.Action.increase }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        decreaseButton.rx.tap
            .map { Reactor.Action.decrease }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        reactor.state.map { $0.value }
            .distinctUntilChanged()
            .map { "\($0)" }
            .bind(to: valueLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .bind(to: activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)
        
        reactor.state.map {
            $0.hoge
        }
        .debug()
            .subscribe(onNext: {
                $0
            })
            .disposed(by: disposeBag)
        
    }
}


import ReactorKit
import RxSwift

final class CounterViewReactor: Reactor {
    enum Action {
        case increase
        case decrease
        case hoge
    }
    
    enum Mutation {
        case increaseValue
        case decreaseValue
        case setLoading(Bool)
        case hoge
    }
    
    struct State {
        var value: Int
        var isLoading: Bool
        var hoge: String
    }
    
    let initialState: State
    
    init() {
        self.initialState = State(
            value: 0,
            isLoading: false,
            hoge: ""
        )
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .increase:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                Observable.just(Mutation.increaseValue).delay(0.5, scheduler: MainScheduler.instance),
                Observable.just(Mutation.setLoading(false)),
                ])
            
        case .decrease:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                Observable.just(Mutation.decreaseValue).delay(0.5, scheduler: MainScheduler.instance),
                Observable.just(Mutation.setLoading(false)),
                ])
        case .hoge:
            return Observable.just(Mutation.hoge)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .increaseValue:
            state.value += 1
            
        case .decreaseValue:
            state.value -= 1
            
        case let .setLoading(isLoading):
            state.isLoading = isLoading
        case .hoge:
            state.hoge = "aaaaa"
        }
        return state
    }
}
