import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:safe_transfer/transfer/cubit/transfer_cubit.dart';
import 'package:safe_transfer/transfer_order_page.dart';
import 'package:safe_transfer/utils/validator_service.dart';
import 'package:safe_transfer/widgets/account_card.dart';
import 'package:safe_transfer/widgets/custom_app_bar.dart';
import 'package:safe_transfer/widgets/custom_button.dart';
import 'package:safe_transfer/widgets/custom_text_input.dart';

class TransferPage extends StatelessWidget {
  TransferPage({super.key});

  final TextEditingController payeeFullNameController = TextEditingController();
  final TextEditingController sortCodeController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransferCubit(),
      child: Builder(
        builder: (context) {
          return BlocListener<TransferCubit, TransferState>(
            listener: (context, state) {
              if (state is TransferLoading) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                );
              } else if (state is TransferError) {
                Navigator.of(context).pop();
                AwesomeDialog(
                  context: context,
                  dialogType: DialogType.error,
                  animType: AnimType.bottomSlide,
                  title: 'Error',
                  desc: state.message,
                  btnCancelOnPress: () {},
                  btnCancelText: 'Close',
                ).show();
              }
              if (state is TransferCreated) {
                FocusScope.of(context).requestFocus(FocusNode());
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => TransferOrderPage(
                      id: state.id,
                      payeeFullName: state.payeeFullName,
                      sortCode: state.sortCode,
                      accountNumber: state.accountNumber,
                      amount: state.amount,
                    ),
                  ),
                );
              }
            },
            child: Scaffold(
              appBar: const CustomAppBar(
                title: 'Transfer',
              ),
              body: Container(
                color: const Color(0xFFFAFAFA),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const Expanded(child: SizedBox()),
                        Image.asset(
                          'assets/images/bg_transfer.png',
                          width: double.infinity,
                          height: 200,
                        ),
                      ],
                    ),
                    ListView(
                      children: [
                        const SizedBox(height: 20),
                        // 卡片缩进16
                        const Padding(
                          padding: EdgeInsets.only(left: 16, right: 16),
                          child: AccountCard(),
                        ),
                        // 输入部分缩进32
                        Padding(
                          padding: const EdgeInsets.only(left: 32, right: 32),
                          child: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                // 输入框
                                const SizedBox(height: 20),
                                CustomTextInput(
                                  hintText: 'Payee Full Name',
                                  controller: payeeFullNameController,
                                  validator: ValidatorService.validateName,
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 8),
                                CustomTextInput(
                                  hintText: 'Sort Code',
                                  controller: sortCodeController,
                                  validator: ValidatorService.validateNumber,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 8),
                                CustomTextInput(
                                  hintText: 'Account Number',
                                  controller: accountNumberController,
                                  validator: ValidatorService.validateAccountNumber,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 8),
                                CustomTextInput(
                                  hintText: '£ Amount',
                                  controller: amountController,
                                  validator: ValidatorService.validateNumber,
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 12),
                                // 按钮
                                CustomButton(
                                  text: 'Send Transfer',
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      context.read<TransferCubit>().createTransfer(
                                            payeeFullName:
                                                payeeFullNameController.text,
                                            sortCode:
                                                int.tryParse(sortCodeController.text),
                                            accountNumber:
                                                accountNumberController.text,
                                            amount: double.parse(amountController.text),
                                          );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
