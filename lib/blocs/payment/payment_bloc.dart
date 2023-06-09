import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:stripe_platform_interface/src/models/card_field_input.dart';
import 'package:stripe_platform_interface/src/models/card_field_input.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:stripe_platform_interface/src/models/payment_methods.dart';
import 'package:http/http.dart' as http;
part 'payment_event.dart';
part 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(const PaymentState()) {
    on<PaymentStart>(_onPaymentStart);
    on<PaymentCreateIntent>(_onCreateIntent);
    on<PaymentConfirmIntent>(_onConfirmIntent);
  }

  FutureOr<void> _onPaymentStart(
    PaymentStart event,
    Emitter<PaymentState> emit,
  ) {
    emit(state.copyWith(status: PaymentStatus.initial));
  }

  Future<FutureOr<void>> _onCreateIntent(
    PaymentCreateIntent event,
    Emitter<PaymentState> emit,
  ) async {
    emit(state.copyWith(status: PaymentStatus.loading));
    // 改UI
    final paymentMethod = await Stripe.instance.createPaymentMethod(
      PaymentMethodParams.card(
        paymentMethodData:
            PaymentMethodData(billingDetails: event.billingDetails),
      ),
    );
    final paymentIntentResults = await _callPayEndpointMethodId(
      useStripeSdk: true,
      paymentMethodId: paymentMethod.id,
      currency: 'usd',
      items: event.items,
    );

    /// fail的话
    if (paymentIntentResults['error'] != null) {
      emit(state.copyWith(status: PaymentStatus.failure));
    }

    // /// success   但是在server里使用的  requires_action？？？？？？？？？？TODO
    // if (paymentIntentResults['clientSecret'] != null &&
    //     paymentIntentResults['requiresAction'] == null) {
    //   emit(state.copyWith(status: PaymentStatus.success));
    // }
    /// success
    if (paymentIntentResults['status']   == 'succeeded') {
      emit(state.copyWith(status: PaymentStatus.success));
    }

    ///  require Action
    if (paymentIntentResults['clientSecret'] != null &&
        paymentIntentResults['requiresAction'] == true) {
      final String clientSecret = paymentIntentResults['clientSecret'];
      add(PaymentConfirmIntent(clientSecret: clientSecret));
    }
  }

  ///  确认
  FutureOr<void> _onConfirmIntent(
    PaymentConfirmIntent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      final paymentIntent =
          await Stripe.instance.handleNextAction(event.clientSecret);
      if (paymentIntent.status == PaymentIntentsStatus.RequiresConfirmation) {
        Map<String, dynamic> results = await _callPayEndpointIntentId(
          paymentIntentId: paymentIntent.id,
        );

        if (results['error'] != null) {
          /// fail
          emit(state.copyWith(status: PaymentStatus.failure));
        } else {
          /// success
          emit(state.copyWith(status: PaymentStatus.success));
        }
      }
    } catch (e) {
      print(e);
      emit(state.copyWith(status: PaymentStatus.failure));
    }
  }

  /// 调用 firebase的后端
  Future<Map<String, dynamic>> _callPayEndpointIntentId({
    required String paymentIntentId,
  }) async {
    final url = Uri.parse(
        'https://us-central1-flutter-payment-stripe-demo.cloudfunctions.net/StripePayEndpointIntentId');
    // 发post 请求
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'paymentIntentId': paymentIntentId,
      }),
    );
    return json.decode(response.body);
  }

  /// 调用 firebase的  MethodId 后端
  Future<Map<String, dynamic>> _callPayEndpointMethodId({
    required bool useStripeSdk,
    required String paymentMethodId,
    required String currency,
    required List<Map<String, dynamic>> items,
  }) async {
    final url = Uri.parse(
        'https://us-central1-flutter-payment-stripe-demo.cloudfunctions.net/StripePayEndpointMethodId');
    // 发post 请求
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'useStripeSdk': useStripeSdk,
        'paymentMethodId': paymentMethodId,
        'currency': currency,
        'items': items,
      }),
    );
    return json.decode(response.body);
  }
}
