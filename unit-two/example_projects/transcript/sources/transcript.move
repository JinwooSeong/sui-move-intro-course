// Copyright (c) 2022, Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/// A basic object example for Sui Move, part of the Sui Move intro course:
/// https://github.com/sui-foundation/sui-move-intro-course
/// 
module sui_intro_unit_two::transcript {

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::dynamic_object_field as ofield;

    struct Transcript {
        history: u8,
        math: u8,
        literature: u8,
    }

    struct TranscriptObject has key {
        id: UID,
        english: u8,
        math: u8,
        literature: u8,
    }

    struct Folder {
        id: UID,
        transcript: TranscriptObject,
    }

    struct Envelope has key {
        id: UID
    }

    public entry fun create_transcript_object(history: u8, math: u8, literature: u8, ctx: &mut TxContext) {
        let transcriptObject = TranscriptObject {
            id: object::new(ctx),
            history,
            math,
            literature,
        };
        transfer::transfer(transcriptObject, tx_context::sender(ctx))
    }

    // You are allowed to view the score but cannot modify it
    public entry fun view_score(transcriptObject: &TranscriptObject): u8{
        transcriptObject.literature
    }

    // You are allowed to view and edit the score but not allowed to delete it
    public entry fun update_score(transcriptObject: &mut TranscriptObject, score: u8){
        transcriptObject.literature = score
    }

    // You are allowed to do anything with the score, including view, edit, delete the entire transcript itself.
    public entry fun delete_transcript(transcriptObject: TranscriptObject){
        let TranscriptObject {id, history: _, math: _, literature: _ } = transcriptObject;
        object::delete(id);
    }

    public entry fun add_transcript(envelope: &mut Envelope, transcript: TranscriptObject) {
        ofield::add(&mut envelope.id, b"transcript", transcript);
    }

    // If you just want to get a score
    public entry fun get_english_score(envelope: &Envelope): u8 {
        let transcript = ofield::borrow<vector<u8>, Transcript>(&mut envelope.id, b"transcript");
        transcript.history
    }

    // If you wish to update your history score
    public entry fun update_english_score(envelope: &Envelope, score: u8){
        let transcript = ofield::borrow_mut<vector<u8>, Transcript>(&mut envelope.id, b"transcript");
        transcript.history = score;
    }

    // If you wish to take out your transcript from the envelope.
    public entry fun remove_transcript_from_envelope(envelope: &mut Envelope) {
        let Transcript { id, history: _, math: _, literature: _ } = ofield::remove<vector<u8>, Child>(
            &mut envelope.id,
            b"transcript",
        );
        // object::delete(id); // step is used if you want to delete the transcript instance.
    }

}