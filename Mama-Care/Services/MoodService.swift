//
//  MoodService.swift
//  Mama-Care
//
//  Created by Udodirim Offia on 24/11/2025.
//

import Foundation
import FirebaseFirestore
import Combine

// MARK: - Mood Service Protocol

protocol MoodServiceProtocol: AnyObject {
    func addMood(_ mood: MoodCheckIn, userID: String) async throws
    func fetchMoods(userID: String) async throws -> [MoodCheckIn]
    func deleteMood(moodID: String, userID: String) async throws
}

// MARK: - Mood Service Implementation

final class MoodService: MoodServiceProtocol {
    static let shared = MoodService()
    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Add Mood (Async)

    func addMood(_ mood: MoodCheckIn, userID: String) async throws {
        let collection = db.collection("users").document(userID).collection("moods")
        try collection.addDocument(from: mood)
    }

    // MARK: - Fetch Moods (Async)

    func fetchMoods(userID: String) async throws -> [MoodCheckIn] {
        let snapshot = try await db.collection("users")
            .document(userID)
            .collection("moods")
            .order(by: "date", descending: true)
            .getDocuments()

        return try snapshot.documents.compactMap { document in
            try document.data(as: MoodCheckIn.self)
        }
    }

    // MARK: - Delete Mood (Async)

    func deleteMood(moodID: String, userID: String) async throws {
        try await db.collection("users")
            .document(userID)
            .collection("moods")
            .document(moodID)
            .delete()
    }

    // MARK: - Legacy Combine Support (for backward compatibility)

    func addMoodPublisher(_ mood: MoodCheckIn, userID: String) -> Future<Void, Error> {
        Future { promise in
            do {
                try self.db.collection("users").document(userID).collection("moods").addDocument(from: mood) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }
    }

    func fetchMoodsPublisher(userID: String) -> Future<[MoodCheckIn], Error> {
        Future { promise in
            self.db.collection("users").document(userID).collection("moods")
                .order(by: "date", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard let documents = snapshot?.documents else {
                        promise(.success([]))
                        return
                    }

                    do {
                        let moods = try documents.compactMap { try $0.data(as: MoodCheckIn.self) }
                        promise(.success(moods))
                    } catch {
                        promise(.failure(error))
                    }
                }
        }
    }
}
