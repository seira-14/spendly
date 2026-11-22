<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Expense;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // 1. Create Default Categories
        $categoriesData = [
            ['name' => 'Kebutuhan', 'icon' => 'wallet', 'color' => '#FF6584'],
            ['name' => 'Keinginan', 'icon' => 'shopping-bag', 'color' => '#B37DFF'],
            ['name' => 'Transportasi', 'icon' => 'car', 'color' => '#FF8A65'],
            ['name' => 'Lainnya', 'icon' => 'more-horizontal', 'color' => '#4DD0E1'],
            ['name' => 'Makanan', 'icon' => 'coffee', 'color' => '#FFB74D'],
            ['name' => 'Belanja', 'icon' => 'shopping-cart', 'color' => '#4DB6AC'],
            ['name' => 'Hadiah', 'icon' => 'gift', 'color' => '#F06292'],
        ];

        $categories = [];
        foreach ($categoriesData as $cat) {
            $categories[$cat['name']] = Category::create($cat);
        }

        // 2. Create User Nayla
        $user = User::create([
            'name' => 'Nayla',
            'email' => 'nayla@spendly.id',
            'password' => Hash::make('password123'),
        ]);

        // 3. Seed Realistic Expenses for Nayla
        $now = Carbon::now();
        $currentYear = $now->year;
        $currentMonth = $now->month;

        $marchExpenses = [
            [
                'title' => 'Supermarket',
                'category_id' => $categories['Kebutuhan']->id,
                'amount' => 150000,
                'date' => Carbon::create(2025, 3, 23)->format('Y-m-d'),
                'notes' => 'Belanja kebutuhan mingguan sayur dan buah di Supermarket',
            ],
            [
                'title' => 'Kopi Kenangan',
                'category_id' => $categories['Keinginan']->id,
                'amount' => 45000,
                'date' => Carbon::create(2025, 3, 22)->format('Y-m-d'),
                'notes' => 'Kopi Kenangan Mantan Large + Toast',
            ],
            [
                'title' => 'Bensin',
                'category_id' => $categories['Transportasi']->id,
                'amount' => 50000,
                'date' => Carbon::create(2025, 3, 12)->format('Y-m-d'),
                'notes' => 'Isi Pertamax full tank motor',
            ],
            [
                'title' => 'Kado Ulang Tahun',
                'category_id' => $categories['Lainnya']->id,
                'amount' => 200000,
                'date' => Carbon::create(2025, 3, 10)->format('Y-m-d'),
                'notes' => 'Kado kemeja dan boneka ulang tahun teman',
            ],
            [
                'title' => 'Belanja Bulanan',
                'category_id' => $categories['Kebutuhan']->id,
                'amount' => 800000,
                'date' => Carbon::create(2025, 3, 5)->format('Y-m-d'),
                'notes' => 'Beras, minyak, sabun, dan kebutuhan pokok bulanan',
            ],
            [
                'title' => 'Listrik & Air PAM',
                'category_id' => $categories['Kebutuhan']->id,
                'amount' => 300000,
                'date' => Carbon::create(2025, 3, 2)->format('Y-m-d'),
                'notes' => 'Token listrik PLN 200rb dan tagihan air 100rb',
            ],
            [
                'title' => 'Baju Baru & Outfit',
                'category_id' => $categories['Keinginan']->id,
                'amount' => 355000,
                'date' => Carbon::create(2025, 3, 15)->format('Y-m-d'),
                'notes' => 'Beli kardigan dan rok di mall',
            ],
            [
                'title' => 'Nonton Bioskop',
                'category_id' => $categories['Keinginan']->id,
                'amount' => 100000,
                'date' => Carbon::create(2025, 3, 8)->format('Y-m-d'),
                'notes' => 'Tiket XXI + Popcorn caramel',
            ],
            [
                'title' => 'Skincare & Make Up',
                'category_id' => $categories['Keinginan']->id,
                'amount' => 250000,
                'date' => Carbon::create(2025, 3, 12)->format('Y-m-d'),
                'notes' => 'Serum wajah dan sunscreen',
            ],
            [
                'title' => 'Ojek Online',
                'category_id' => $categories['Transportasi']->id,
                'amount' => 100000,
                'date' => Carbon::create(2025, 3, 18)->format('Y-m-d'),
                'notes' => 'Ongkos Gojek bolak-balik kantor',
            ],
            [
                'title' => 'Service Motor',
                'category_id' => $categories['Transportasi']->id,
                'amount' => 100000,
                'date' => Carbon::create(2025, 3, 4)->format('Y-m-d'),
                'notes' => 'Ganti oli dan servis rutin bengkel',
            ],
        ];

        foreach ($marchExpenses as $exp) {
            $user->expenses()->create($exp);
        }

        // Also add some expenses for current month ($currentYear-$currentMonth) if different from March 2025
        if ($currentYear != 2025 || $currentMonth != 3) {
            $currentExpenses = [
                [
                    'title' => 'Supermarket',
                    'category_id' => $categories['Kebutuhan']->id,
                    'amount' => 150000,
                    'date' => $now->copy()->format('Y-m-d'),
                    'notes' => 'Belanja kebutuhan harian',
                ],
                [
                    'title' => 'Kopi Kenangan',
                    'category_id' => $categories['Keinginan']->id,
                    'amount' => 45000,
                    'date' => $now->copy()->subDay()->format('Y-m-d'),
                    'notes' => 'Kopi dan cemilan',
                ],
                [
                    'title' => 'Bensin Pertamax',
                    'category_id' => $categories['Transportasi']->id,
                    'amount' => 50000,
                    'date' => $now->copy()->subDays(3)->format('Y-m-d'),
                    'notes' => 'Bensin motor',
                ],
                [
                    'title' => 'Kado Ulang Tahun',
                    'category_id' => $categories['Lainnya']->id,
                    'amount' => 200000,
                    'date' => $now->copy()->subDays(5)->format('Y-m-d'),
                    'notes' => 'Kado ultah sahabat',
                ],
                [
                    'title' => 'Belanja Bulanan Pokok',
                    'category_id' => $categories['Kebutuhan']->id,
                    'amount' => 1100000,
                    'date' => $now->copy()->startOfMonth()->addDays(2)->format('Y-m-d'),
                    'notes' => 'Kebutuhan pokok',
                ],
                [
                    'title' => 'Makan Restoran',
                    'category_id' => $categories['Keinginan']->id,
                    'amount' => 705000,
                    'date' => $now->copy()->subDays(8)->format('Y-m-d'),
                    'notes' => 'Makan malam keluarga',
                ],
                [
                    'title' => 'Transportasi Kereta / Tol',
                    'category_id' => $categories['Transportasi']->id,
                    'amount' => 200000,
                    'date' => $now->copy()->subDays(10)->format('Y-m-d'),
                    'notes' => 'Tiket transportasi',
                ],
            ];

            foreach ($currentExpenses as $exp) {
                $user->expenses()->create($exp);
            }
        }
    }
}
