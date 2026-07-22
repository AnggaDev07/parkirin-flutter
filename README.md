# 🅿️ Parkirin - Batam City Cashless Parking Payment System[cite: 8]

**Parkirin** is a smart mobile application (*on-street parking*) specifically designed to modernize the parking system in Batam City[cite: 8]. This application digitalizes the vehicle recording process and facilitates *cashless* payment transactions, creating a more transparent, fast, and efficient parking experience for both drivers and parking attendants[cite: 8].

---

## 🛠️ Technologies & Architecture (Tech Stack)[cite: 8]

This application is built with a focus on high performance and maintainable code using **Flutter Clean Architecture** (divided into *Entities, Use Cases, Repository/Presenter, and Data Source/UI*)[cite: 8].

*   **Programming Language:** Dart[cite: 8]
*   **Framework:** Flutter[cite: 8]
*   **Database (BaaS):** Firebase (Authentication & Firestore)[cite: 8]
*   **Payment Gateway:** Midtrans (Integrated for *cashless* payment methods)[cite: 8]
*   **UI/UX Design:** Figma[cite: 8]

---

## ✨ Key Features[cite: 8]

This system separates the workflow into two main roles[cite: 8]:

### 🚗 Driver Side[cite: 8]
*   **Easy Authentication:** Register and log in using a Phone Number (OTP verification) or direct integration with a Google Account[cite: 8].
*   **Vehicle Management (CRUD):** Register, update, or delete license plates and vehicle types within the profile[cite: 8].
*   **Flexible Payment:** Pay parking bills *cashless* through various payment methods (*Payment Gateway*), or use the Point redemption system (Redeem 2000 Points for 1x free parking)[cite: 8].
*   **Parking History:** Monitor the complete trail of parking activities and previously made payment statuses[cite: 8].

### 👷 Parking Attendant Side[cite: 8]
*   **Secure Login:** Uses the Parking Attendant Identification Number (NIJP) and a specific password registered in the system[cite: 8].
*   **Fast Ticket Creation:** Issue new parking tickets by inputting the vehicle type, license plate, and payment method (*Bill Driver* for app users, or *Record Parking* for non-app users)[cite: 8].
*   **Editing Flexibility:** Feature to update or correct parking ticket details (valid before the 10-minute time limit since the ticket was created)[cite: 8].
*   **Daily Statistics:** A dedicated dashboard displaying the total number of tickets, pending tickets, paid tickets, and estimated revenue in *real-time*[cite: 8].

---