import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _orgCodeController = TextEditingController();

  String _selectedRole = "Oyuncu";
  bool _consentLegal = false;
  bool _consentCommercial = false;
  bool _isLoading = false;

  final String _secretOrgCode = "ORG-2026";

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _usernameController.text.isEmpty) {
      _showError("Lütfen gerekli tüm alanları doldurun.");
      return;
    }
    if (!_consentLegal) {
      _showError("Kayıt olmak için Açık Rıza Metnini onaylamalısınız.");
      return;
    }
    if (_selectedRole == "Organizatör" &&
        _orgCodeController.text.trim() != _secretOrgCode) {
      _showError("Geçersiz Organizatör Doğrulama Kodu!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'email': _emailController.text.trim(),
            'username': _usernameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'role': _selectedRole.toUpperCase(),
            'commercialConsent': _consentCommercial,
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hesabınız başarıyla oluşturuldu!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Kayıt başarısız.";
      if (e.code == 'email-already-in-use')
        msg = 'Bu e-posta zaten kullanımda.';
      if (e.code == 'weak-password') msg = 'Şifre çok zayıf.';
      _showError(msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String text) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(text), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "Kaydol",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    "Email",
                    _emailController,
                    Icons.email,
                    maxLength: 40,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Şifre",
                    _passwordController,
                    Icons.lock,
                    isPassword: true,
                    maxLength: 20,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Telefon Numarası",
                    _phoneController,
                    Icons.phone,
                    isNumber: true,
                    maxLength: 15,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    "Kullanıcı Adı",
                    _usernameController,
                    Icons.person,
                    maxLength: 15,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio<String>(
                        value: "Oyuncu",
                        groupValue: _selectedRole,
                        activeColor: const Color(0xFFBB86FC),
                        onChanged: (val) =>
                            setState(() => _selectedRole = val!),
                      ),
                      const Text(
                        "Oyuncu",
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Radio<String>(
                        value: "Organizatör",
                        groupValue: _selectedRole,
                        activeColor: const Color(0xFFBB86FC),
                        onChanged: (val) =>
                            setState(() => _selectedRole = val!),
                      ),
                      const Text(
                        "Organizatör",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  if (_selectedRole == "Organizatör") ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _orgCodeController,
                      style: const TextStyle(color: Colors.orange),
                      decoration: InputDecoration(
                        labelText: "Organizatör Doğrulama Kodu",
                        labelStyle: const TextStyle(color: Colors.orangeAccent),
                        prefixIcon: const Icon(
                          Icons.vpn_key,
                          color: Colors.orangeAccent,
                        ),
                        filled: true,
                        fillColor: Colors.orange.withAlpha(20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.orange),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Colors.orangeAccent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        "* Yetkili hesap açmak için kurum kodunu girmelisiniz.",
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  _buildCheckbox(
                    "Açık Rıza Onayı - Yasal Yükümlülük",
                    _consentLegal,
                    (val) => setState(() => _consentLegal = val!),
                  ),
                  _buildCheckbox(
                    "Verilerin İşlenmesi - Ticari E-mail",
                    _consentCommercial,
                    (val) => setState(() => _consentCommercial = val!),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBB86FC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : _signUp,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Kaydol",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Zaten hesabınız var mı? ",
                  style: TextStyle(color: Colors.grey),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    "Giriş Yapın",
                    style: TextStyle(
                      color: Color(0xFFBB86FC),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isPassword = false,
    bool isNumber = false,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      inputFormatters: maxLength != null
          ? [LengthLimitingTextInputFormatter(maxLength)]
          : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFFBB86FC), size: 20),
        filled: true,
        fillColor: Colors.grey[900],
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBB86FC)),
        ),
      ),
    );
  }

  Widget _buildCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: value,
            activeColor: const Color(0xFFBB86FC),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
