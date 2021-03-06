/*---------------------------------------------------------------------------------------------
*  Copyright (c) nt4f04und. All rights reserved.
*  Licensed under the BSD-style license. See LICENSE in the project root for license information.
*--------------------------------------------------------------------------------------------*/

import 'package:enum_to_string/enum_to_string.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:sweyer/logic/logic.dart';

/// Inteface for other sort feature enums.
abstract class SortFeature {
  const SortFeature._(this._value);
  final String _value;
  String get value => _value;
  String toString() => '$runtimeType.$value';
  bool get defaultOrderAscending;

  static List<SortFeature> getValues<T extends Sort>() {
    switch (T) {
      case SongSort:
        return SongSortFeature.values;
      case AlbumSort:
        return AlbumSortFeature.values;
      default:
        assert(false);
        return null;
    }
  }
}

/// Features to sort by a [Song] list.
///
/// Each feature also has the default sort order - ASC or DESC.
/// When user changes the [SongSortFeature] the new default sort order is applied.
class SongSortFeature extends SortFeature {
  const SongSortFeature._(String value) : super._(value);

  static List<SongSortFeature> get values {
    return [dateModified, dateAdded, title, artist, album];
  }

  @override
  bool get defaultOrderAscending => this != dateModified && this != dateAdded;

  /// Sort by the [Song.dateModified].
  /// Default sort order is DESC.
  static const dateModified = const SongSortFeature._('dateModified');

  /// Sort by the [Song.dateAdded].
  /// Default sort order is DESC.
  static const dateAdded = const SongSortFeature._('dateAdded');

  /// Sort by the [Song.title].
  /// Default sort order is ASC.
  static const title = const SongSortFeature._('title');

  /// Sort by the [Song.artist].
  /// Default sort order is ASC.
  static const artist = const SongSortFeature._('artist');

  /// Sort by the [Song.album].
  /// Default sort order is ASC.
  static const album = const SongSortFeature._('album');
}

/// Features to sort by a [Album] list.
///
/// Each feature also has the default sort order - ASC or DESC.
/// When user changes the [AlbumSortFeature] the new default sort order is applied.
class AlbumSortFeature extends SortFeature {
  const AlbumSortFeature._(String value) : super._(value);

  bool get defaultOrderAscending => this != year;

  static List<AlbumSortFeature> get values {
    return [title, artist, year, numberOfSongs];
  }

  /// Sort by the [Album.album].
  /// Default sort order is ASC.
  static const title = const AlbumSortFeature._('title');

  /// Sort by the [Album.artist].
  /// Default sort order is ASC.
  static const artist = const AlbumSortFeature._('artist');

  /// Sort by the [Album.lastYear].
  /// Default sort order is DESC.
  static const year = const AlbumSortFeature._('year');

  /// Sort by the [Album.numberOfSongs].
  /// Default sort order is ASC.
  static const numberOfSongs = const AlbumSortFeature._('numberOfSongs');
}

/// Picks some value based on the provided sort type [T].
V sortPick<T extends Sort, V>({@required V song, @required V album}) {
  switch (T) {
    case SongSort:
      return song;
    case AlbumSort:
      return album;
    default:
      assert(false);
      return null;
  }
}

abstract class Sort<T> extends Equatable {
  const Sort({
    @required this.feature,
    @required this.orderAscending,
  })  : assert(feature != null),
        assert(orderAscending != null);
  Sort.defaultOrder(this.feature)
      : orderAscending = feature.defaultOrderAscending;

  final SortFeature feature;
  final bool orderAscending;

  @override
  List<Object> get props => [feature, orderAscending];

  Sort<T> copyWith({SortFeature feature, bool orderAscending});
  Sort<T> get withDefaultOrder;

  Comparator<T> get comparator;
}

class SongSort extends Sort<Song> {
  const SongSort({
    @required this.feature,
    bool orderAscending = true,
  }) : super(feature: feature, orderAscending: orderAscending);
  SongSort.defaultOrder(this.feature) : super.defaultOrder(feature);

  factory SongSort.fromJson(Map<String, dynamic> json) => SongSort(
        feature: EnumToString.fromString(
          SongSortFeature.values,
          json['feature'],
        ),
        orderAscending: json['orderAscending'],
      );
  Map<String, dynamic> toJson() => {
        'feature': feature.value,
        'orderAscending': orderAscending,
      };

  @override
  final SongSortFeature feature;

  SongSort copyWith({
    covariant SongSortFeature feature,
    bool orderAscending,
  }) {
    return SongSort(
      feature: feature ?? this.feature,
      orderAscending: orderAscending ?? this.orderAscending,
    );
  }

  SongSort get withDefaultOrder {
    return this.copyWith(orderAscending: feature.defaultOrderAscending);
  }

  int _fallbackDateModified(Song a, Song b) {
    return a.dateModified.compareTo(b.dateModified);
  }

  int _fallbackTitle(Song a, Song b) {
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  @override
  Comparator<Song> get comparator {
    Comparator<Song> c;
    switch (feature) {
      case SongSortFeature.dateModified:
        c = (a, b) {
          final compare = a.dateModified.compareTo(b.dateModified);
          if (compare == 0) return _fallbackTitle(a, b);
          return compare;
        };
        break;
      case SongSortFeature.dateAdded:
        c = (a, b) {
          final compare = a.dateAdded.compareTo(b.dateAdded);
          if (compare == 0) return _fallbackTitle(a, b);
          return compare;
        };
        break;
      case SongSortFeature.title:
        c = (a, b) {
          final compare =
              a.title.toLowerCase().compareTo(b.title.toLowerCase());
          if (compare == 0) return _fallbackDateModified(a, b);
          return compare;
        };
        break;
      case SongSortFeature.artist:
        c = (a, b) {
          final compare =
              a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
          if (compare == 0) return _fallbackTitle(a, b);
          return compare;
        };
        break;
      case SongSortFeature.album:
        c = (a, b) {
          final compare =
              a.album.toLowerCase().compareTo(b.album.toLowerCase());
          if (compare == 0) return _fallbackTitle(a, b);
          return compare;
        };
        break;
      default:
        assert(false);
        return null;
    }
    if (!orderAscending) {
      return (a, b) => c(b, a);
    }
    return c;
  }
}

class AlbumSort extends Sort<Album> {
  const AlbumSort({
    @required this.feature,
    bool orderAscending = true,
  }) : super(feature: feature, orderAscending: orderAscending);
  AlbumSort.defaultOrder(this.feature) : super.defaultOrder(feature);

  factory AlbumSort.fromJson(Map<String, dynamic> json) => AlbumSort(
        feature: EnumToString.fromString(
          AlbumSortFeature.values,
          json['feature'],
        ),
        orderAscending: json['orderAscending'],
      );
  Map<String, dynamic> toJson() => {
        'feature': feature.value,
        'orderAscending': orderAscending,
      };

  @override
  final AlbumSortFeature feature;

  AlbumSort copyWith({
    covariant AlbumSortFeature feature,
    bool orderAscending,
  }) {
    return AlbumSort(
      feature: feature ?? this.feature,
      orderAscending: orderAscending ?? this.orderAscending,
    );
  }

  AlbumSort get withDefaultOrder {
    return this.copyWith(orderAscending: feature.defaultOrderAscending);
  }

  int _fallbackYear(Album a, Album b) {
    return a.year.compareTo(b.year);
  }

  int _fallbackTitle(Album a, Album b) {
    return a.album.toLowerCase().compareTo(b.album.toLowerCase());
  }

  @override
  Comparator<Album> get comparator {
    Comparator<Album> c;
    switch (feature) {
      case AlbumSortFeature.title:
        c = (a, b) {
          final compare =
              a.album.toLowerCase().compareTo(b.album.toLowerCase());
          if (compare == 0) return _fallbackYear(a, b);
          return compare;
        };
        break;
      case AlbumSortFeature.artist:
        c = (a, b) {
          final compare =
              a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
          if (compare == 0) return _fallbackYear(a, b);
          return compare;
        };
        break;
      case AlbumSortFeature.year:
        c = (a, b) {
          final compare = a.year.compareTo(b.year);
          if (compare == 0) return _fallbackTitle(a, b);
          return compare;
        };
        break;
      case AlbumSortFeature.numberOfSongs:
        c = (a, b) {
          final compare = a.numberOfSongs.compareTo(b.numberOfSongs);
          if (compare == 0) return _fallbackYear(a, b);
          return compare;
        };
        break;
      default:
        assert(false);
        return null;
    }
    if (!orderAscending) {
      return (a, b) => c(b, a);
    }
    return c;
  }
}
