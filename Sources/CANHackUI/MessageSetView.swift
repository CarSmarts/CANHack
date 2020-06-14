//
//  MessageSetView.swift
//  SmartCar
//
//  Created by Robert Smith on 4/27/20.
//  Copyright © 2020 Robert Smith. All rights reserved.
//

import Combine
import SwiftUI
import CANHack
import AppFolder

@propertyWrapper
public class ObservedSubject<V>: ObservableObject {
    public typealias SubjectType = CurrentValueSubject<V, Never>
    
    public init(wrappedValue: V) {
        self.subject = SubjectType(wrappedValue)
    }
    
    var subject: SubjectType
    
    public var wrappedValue: V {
        get { subject.value }
        set { subject.send(newValue) }
    }

    public var projectedValue: SubjectType {
        get { subject }
    }
}

public class SubjectObserver<V: ObservableObject>: ObservableObject {
    public typealias SubjectType = CurrentValueSubject<V, Never>
    
    private var sub: AnyCancellable?
        
    public var subject: SubjectType? {
        didSet {
            sub = subject?.flatMap { $0.objectWillChange }.sink(receiveCompletion: { _ in }) { _ in
                self.objectWillChange.send()
            }
        }
    }
}

public struct MessageSetView: View {
    @ObservedObject public var document: MessageSetDocument
    @Binding public var decoder: CarDecoder
    
    var groupedByIdSub: AnyCancellable?

    public init(document: MessageSetDocument, decoder: Binding<CarDecoder>) {
        self.document = document
        self._decoder = decoder
        
        groupedSetObserver.subject = $groupedSet
        groupedByIdSub = document.$activeSignalSet.map(\.groupedById).subscribe($groupedSet)
    }
    
    @ObservedObject var groupedSetObserver = SubjectObserver<GroupedSignalSet<Message, MessageID>>()
    @ObservedSubject var groupedSet = SignalSet<Message>().groupedById

    @State var scale = OccuranceGraphScale(min: 0, max: 10)
    
    var scaleUpdatePublisher: AnyPublisher<OccuranceGraphScale, Never> {
        
        document.$activeSignalSet.flatMap { signalSet in
            signalSet.newInstancePublisher.map { _ in () }
        }
        .prepend(())
        .map {
            self.document.activeSignalSet.scale
        }.eraseToAnyPublisher()
    }
    
    public var body: some View {
        List(document.activeSignalSet.ids) { id in
            ZStack {
                MessageStatView(groupStats: self.groupedSet[id], decoder: self.$decoder[id], activeSignal: .constant(Mock.signalInstance), scale: self.$scale)
                
                NavigationLink(destination: MessageDetailView(stats: self.groupedSet[id], decoder: self.$decoder[id]), label: { EmptyView() })
            }
        }.onReceive(scaleUpdatePublisher) { scale in
            self.scale = scale
        }
    }
}

struct MessageSetView_Previews: PreviewProvider {
    static var doc = { () -> MessageSetDocument in
        let doc = MessageSetDocument(fileURL: AppFolder.tmp.url.appendingPathComponent("test"))
        doc.activeSignalSet = Mock.testSet
        return doc
    }()
    
    static var previews: some View {
        MessageSetView(document: doc, decoder: .constant(Mock.decoder))
    }
}
