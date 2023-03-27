//
//  AuthenticationView.swift
//  MarsExplorer
//
//  Created by Muhammed Kocabas on 2023-03-02.
//

import SwiftUI
import Combine
import Firebase
import FirebaseCore
import FirebaseAnalyticsSwift
import FirebaseAuth

struct AuthenticationView: View {
  @EnvironmentObject var viewModel: AuthenticationViewModel

  var body: some View {
    VStack {
      switch viewModel.flow {
      case .login:
        LoginView()
          .environmentObject(viewModel)
      case .signUp:
        SignupView()
          .environmentObject(viewModel)
      }
    }
  }
}

struct AuthenticationView_Previews: PreviewProvider {
  static var previews: some View {
    AuthenticationView()
      .environmentObject(AuthenticationViewModel())
  }
}

