import 'package:equatable/equatable.dart';

enum SearchStatus { all, completed, active }

class SearchFilter extends Equatable {
  final String query;
  final SearchStatus status;
  final DateTime? startDate;
  final DateTime? endDate;

  const SearchFilter({
    this.query = '',
    this.status = SearchStatus.all,
    this.startDate,
    this.endDate,
  });

  SearchFilter copyWith({
    String? query,
    SearchStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  bool get hasFilters {
    return query.isNotEmpty ||
        status != SearchStatus.all ||
        startDate != null ||
        endDate != null;
  }

  @override
  List<Object?> get props => [query, status, startDate, endDate];

  @override
  String toString() {
    return 'SearchFilter{query: $query, status: $status, startDate: $startDate, endDate: $endDate}';
  }
}
