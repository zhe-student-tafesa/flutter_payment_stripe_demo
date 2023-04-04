import 'package:flutter/material.dart';
import 'package:flutter_payment_stripe_demo/blocs/blocs.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CardFormScreen extends StatefulWidget {
  const CardFormScreen({Key? key}) : super(key: key);

  @override
  _CardFormScreenState createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('pay with a credit card'),
      ),
      body: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (BuildContext context, state) {
          CardFormEditController controller = CardFormEditController(
            initialDetails: state.cardFieldInputDetails,
          );
          debugPrint('****STATUS: ${state.status} ');

          if (state.status == PaymentStatus.initial) {
            return Padding(
              padding: EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Card Form',
                    style: TextStyle(fontSize: 25),
                  ),
                  SizedBox(),
                  CardFormField(
                    controller: controller,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      (controller.details.complete)
                          ? context
                              .read<PaymentBloc>()
                              .add(const PaymentCreateIntent(
                                billingDetails: BillingDetails(
                                  email: "frank.zhang.sa.au@gmail.com",
                                ),
                                items: [
                                  {'id': 0},
                                  // {'id': 1},
                                  {'id': 2},
                                ],
                              ))
                          : ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                              content: Text('The form is not complete.'),
                            ));
                    },
                    child: const Text('PAY'),
                  )
                ],
              ),
            );
          }

          if (state.status == PaymentStatus.success) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Payment is successful'),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // 开始 下一次 付款
                      context.read<PaymentBloc>().add(PaymentStart());
                    },
                    child: const Text('back to home'),
                  )
                ],
              ),
            );
          }
          if (state.status == PaymentStatus.failure) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('The Paymnet failed'),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    // 开始 下一次 付款
                    context.read<PaymentBloc>().add(PaymentStart());
                  },
                  child: const Text('Try again'),
                )
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
