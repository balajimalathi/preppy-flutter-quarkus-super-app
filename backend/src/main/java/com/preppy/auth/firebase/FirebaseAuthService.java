package com.preppy.auth.firebase;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import jakarta.enterprise.context.ApplicationScoped;
import jakarta.inject.Inject;

@ApplicationScoped
public class FirebaseAuthService {

    private final FirebaseAuth firebaseAuth;

    @Inject
    FirebaseAuthService(final FirebaseAuth firebaseAuth) {
        this.firebaseAuth = firebaseAuth;
    }

    public FirebaseToken verifyIdToken(final String token) throws FirebaseAuthException {
        return firebaseAuth.verifyIdToken(token);
    }
}
