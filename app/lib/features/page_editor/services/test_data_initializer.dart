// TogetherLog - Test Data Initializer
// Adds sample canvas items for testing the editor

import 'package:flutter/material.dart';
import '../models/canvas_item.dart';
import '../models/editor_state.dart';

/// Initialize editor with test data
EditorState initializeTestData(String entryId) {
  return EditorState(
    entryId: entryId,
    items: [
      // Test photo 1
      CanvasItem.photo(
        id: 'test-photo-1',
        photoUrl: 'https://picsum.photos/400/300',
        position: const Offset(50, 50),
        size: const Size(300, 225),
        zIndex: 0,
      ),
      // Test photo 2
      CanvasItem.photo(
        id: 'test-photo-2',
        photoUrl: 'https://picsum.photos/400/300?random=1',
        position: const Offset(400, 100),
        size: const Size(250, 188),
        rotation: 5,
        zIndex: 1,
      ),
      // Test decoration
      CanvasItem.decoration(
        id: 'test-decoration-1',
        decorationUrl: 'https://picsum.photos/200/200?grayscale',
        position: const Offset(150, 400),
        size: const Size(150, 150),
        rotation: -10,
        zIndex: 2,
      ),
      // Test text
      CanvasItem.text(
        id: 'test-text-1',
        text: 'Summer 2024 ☀️',
        position: const Offset(50, 650),
        size: const Size(400, 80),
        zIndex: 3,
        textStyle: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    ],
    backgroundColor: const Color(0xFFFFF8E7), // Warm cream color
  );
}
