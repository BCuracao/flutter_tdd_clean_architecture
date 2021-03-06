import 'dart:convert';

import 'package:clean_architecture/core/error/exceptions.dart';
import 'package:clean_architecture/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl dataSource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(fixture("trivia.json"), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response("Something went wrong", 404));
  }

  group("getRandomNumberTrivia", () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture("trivia.json")));

    test("""should perform a GET request on a URL with number being 
        the endpoint and with application/json header""", () async {
      // arrange
      setUpMockHttpClientSuccess200();
      // act
      dataSource.getRandomNumberTrivia();
      // assert
      verify(mockHttpClient.get("http://numbersapi.com/random",
          headers: {"Content-Type": "application/json"}));
    });

    test("should return NumberTrivia when the response code is 200 (success)",
        () async {
      // arrange
      setUpMockHttpClientSuccess200();
      // act
      final result = await dataSource.getRandomNumberTrivia();
      // assert
      expect(result, equals(tNumberTriviaModel));
    });

    test("Should throw a ServerException when the respone code is 404 or other",
        () async {
      // arrange
      setUpMockHttpClientFailure404();
      // act
      final call = dataSource.getRandomNumberTrivia;
      // assert
      expect(() => call(), throwsA(isA<ServerException>()));
    });
  });

  group("getConcreteNumberTrivia", () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture("trivia.json")));

    test("""should perform a GET request on a URL with number being 
        the endpoint and with application/json header""", () async {
      // arrange
      setUpMockHttpClientSuccess200();
      // act
      dataSource.getConcretNumberTrivia(tNumber);
      // assert
      verify(mockHttpClient.get("http://numbersapi.com/$tNumber",
          headers: {"Content-Type": "application/json"}));
    });

    test("should return NumberTrivia when the response code is 200 (success)",
        () async {
      // arrange
      setUpMockHttpClientSuccess200();
      // act
      final result = await dataSource.getConcretNumberTrivia(tNumber);
      // assert
      expect(result, equals(tNumberTriviaModel));
    });

    test("Should throw a ServerException when the respone code is 404 or other",
        () async {
      // arrange
      setUpMockHttpClientFailure404();
      // act
      final call = dataSource.getConcretNumberTrivia;
      // assert
      expect(() => call(tNumber), throwsA(isA<ServerException>()));
    });
  });
}
