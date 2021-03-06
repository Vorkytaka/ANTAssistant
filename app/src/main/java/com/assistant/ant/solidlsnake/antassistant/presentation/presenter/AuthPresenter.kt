package com.assistant.ant.solidlsnake.antassistant.presentation.presenter

import com.assistant.ant.solidlsnake.antassistant.domain.entity.Credentials
import com.assistant.ant.solidlsnake.antassistant.domain.interactor.Login
import com.assistant.ant.solidlsnake.antassistant.domain.state.AuthState
import com.assistant.ant.solidlsnake.antassistant.presentation.view.AuthView
import kotlinx.coroutines.launch

class AuthPresenter(private val loginUseCase: Login) : BasePresenter<AuthView>() {

    fun auth(login: String, password: String) = launch {
        view?.setProgress(true)

        loginUseCase.params(Credentials(login, password))
                .execute {
                    when (it) {
                        is AuthState.Success -> view?.success()
                        is AuthState.Error -> view?.error()
                    }
                }

        view?.setProgress(false)
    }
}