<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Authenticate or sync user from Firebase (Google Sign-In / Firebase Auth)
     */
    public function firebaseSync(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|string|email|max:255',
            'name' => 'nullable|string|max:255',
            'avatar' => 'nullable|string|max:1000',
            'firebase_uid' => 'nullable|string|max:255',
        ]);

        $email = strtolower(trim($validated['email']));
        $name = !empty($validated['name']) ? trim($validated['name']) : explode('@', $email)[0];
        $avatar = $validated['avatar'] ?? null;

        $user = User::where('email', $email)->first();

        if (!$user) {
            $user = User::create([
                'name' => $name,
                'email' => $email,
                'password' => Hash::make(Str::random(32)),
                'avatar' => $avatar,
            ]);
        } else {
            $updated = false;
            if (!empty($validated['name']) && (empty($user->name) || $user->name === 'User')) {
                $user->name = $name;
                $updated = true;
            }
            if (!empty($avatar) && empty($user->getRawOriginal('avatar'))) {
                $user->avatar = $avatar;
                $updated = true;
            }
            if ($updated) {
                $user->save();
            }
        }

        $token = $user->createToken('spendly_auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Autentikasi Firebase berhasil!',
            'data' => [
                'user' => $user,
                'token' => $token,
            ],
        ]);
    }
    /**
     * Register a new user
     */
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
            'avatar' => 'nullable|string|max:500',
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'avatar' => $validated['avatar'] ?? null,
        ]);

        $token = $user->createToken('spendly_auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Registrasi berhasil!',
            'data' => [
                'user' => $user,
                'token' => $token,
            ],
        ], 201);
    }

    /**
     * Login user and issue token
     */
    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|string|email',
            'password' => 'required|string',
        ]);

        $user = User::where('email', $validated['email'])->first();

        if (!$user || !Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Email atau password salah.',
            ], 401);
        }

        $token = $user->createToken('spendly_auth_token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Login berhasil!',
            'data' => [
                'user' => $user,
                'token' => $token,
            ],
        ]);
    }

    /**
     * Get authenticated user profile
     */
    public function user(Request $request): JsonResponse
    {
        return response()->json([
            'status' => 'success',
            'data' => [
                'user' => $request->user(),
            ],
        ]);
    }

    /**
     * Update user profile
     */
    public function updateProfile(Request $request): JsonResponse
    {
        $user = $request->user();

        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'email' => 'sometimes|required|string|email|max:255|unique:users,email,' . $user->id,
            'password' => 'nullable|string|min:6',
            'avatar' => 'nullable|string|max:500',
        ]);

        if (isset($validated['name'])) {
            $user->name = $validated['name'];
        }

        if (isset($validated['email'])) {
            $user->email = $validated['email'];
        }

        if (!empty($validated['password'])) {
            $user->password = Hash::make($validated['password']);
        }

        if (array_key_exists('avatar', $validated)) {
            $rawAvatar = $user->getRawOriginal('avatar');
            if ($rawAvatar && Storage::disk('public')->exists($rawAvatar)) {
                Storage::disk('public')->delete($rawAvatar);
            }
            $user->avatar = $validated['avatar'];
        }

        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Profil berhasil diperbarui!',
            'data' => [
                'user' => $user,
            ],
        ]);
    }

    /**
     * Upload custom profile photo
     */
    public function uploadAvatar(Request $request): JsonResponse
    {
        $request->validate([
            'avatar' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:5120',
        ]);

        $user = $request->user();

        // Delete old uploaded file if existed
        $rawAvatar = $user->getRawOriginal('avatar');
        if ($rawAvatar && Storage::disk('public')->exists($rawAvatar)) {
            Storage::disk('public')->delete($rawAvatar);
        }

        $path = $request->file('avatar')->store('avatars', 'public');
        $user->avatar = $path;
        $user->save();

        return response()->json([
            'status' => 'success',
            'message' => 'Foto profil berhasil diunggah! ✨',
            'data' => [
                'user' => $user,
            ],
        ]);
    }

    /**
     * Logout user and revoke token
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Logout berhasil!',
        ]);
    }
}
