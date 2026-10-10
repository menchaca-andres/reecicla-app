import SwiftUI

struct QuotationView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var vm = QuotationViewModel()

    @State private var deviceTypes: [CatalogDeviceType] = []
    @State private var devices: [CatalogDevice] = []
    @State private var selectedTypeID: String?
    @State private var selectedDeviceID: String?
    @State private var selectedCondition: DeviceCondition = .working
    @State private var searchText = ""
    @State private var isLoadingTypes = true
    @State private var isLoadingDevices = false
    @State private var catalogError: String?
    @State private var showResult = false

    private var tenantId: String {
        authVM.currentUser?.tenant_id ?? "reecicla"
    }

    private var selectedDevice: CatalogDevice? {
        devices.first { $0.id == selectedDeviceID }
    }

    private var filteredDevices: [CatalogDevice] {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return devices
        }
        let query = searchText.lowercased()
        return devices.filter {
            ($0.brand_name ?? "").lowercased().contains(query)
                || $0.model.lowercased().contains(query)
                || String($0.year ?? 0).contains(query)
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 36) {
                    if let error = catalogError ?? vm.errorMessage {
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                            Text(error)
                            Spacer(minLength: 0)
                        }
                        .font(.system(size: 13))
                        .foregroundColor(.redPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.redPrimary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.redPrimary.opacity(0.2), lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        sectionLabel("Equipos")
                        if isLoadingTypes {
                            statusText("Cargando tipos de equipo...")
                        } else if deviceTypes.isEmpty {
                            statusText("No hay tipos activos disponibles.")
                        } else {
                            LazyVGrid(columns: adaptiveColumns, spacing: 14) {
                                ForEach(deviceTypes) { deviceType in
                                    selectionCard(
                                        title: deviceType.name,
                                        subtitle: nil,
                                        isSelected: selectedTypeID == deviceType.id
                                    ) {
                                        guard selectedTypeID != deviceType.id else { return }
                                        selectedTypeID = deviceType.id
                                        selectedDeviceID = nil
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        sectionLabel("Modelos")
                        if isLoadingDevices {
                            statusText("Cargando modelos disponibles...")
                        } else if devices.isEmpty {
                            Text("No hay dispositivos registrados para este tipo. Contactá al administrador.")
                                .font(.system(size: 13))
                                .foregroundColor(.orangePrimary)
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.orangePrimary.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.orangePrimary.opacity(0.2), lineWidth: 1))
                        } else {
                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 14))
                                    .foregroundColor(.textMuted)
                                TextField("Buscar por marca, modelo o año...", text: $searchText)
                                    .font(.system(size: 13))
                                    .autocorrectionDisabled()
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 44)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.15), lineWidth: 1))

                            if filteredDevices.isEmpty {
                                Text("Sin resultados para \"\(searchText)\"")
                                    .font(.system(size: 13))
                                    .foregroundColor(.textMuted)
                                    .frame(maxWidth: .infinity)
                                    .padding(16)
                            } else {
                                LazyVGrid(columns: adaptiveColumns, spacing: 14) {
                                    ForEach(filteredDevices) { device in
                                        selectionCard(
                                            title: [device.brand_name, device.model]
                                                .compactMap { $0 }
                                                .filter { !$0.isEmpty }
                                                .joined(separator: " "),
                                            subtitle: device.year.map(String.init),
                                            isSelected: selectedDeviceID == device.id
                                        ) {
                                            selectedDeviceID = device.id
                                        }
                                    }
                                }
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        sectionLabel("Condición")
                        LazyVGrid(columns: adaptiveColumns, spacing: 14) {
                            ForEach(DeviceCondition.allCases, id: \.self) { condition in
                                selectionCard(
                                    title: condition.label,
                                    subtitle: condition.description,
                                    isSelected: selectedCondition == condition
                                ) {
                                    selectedCondition = condition
                                }
                            }
                        }
                    }

                    Button(action: submitQuote) {
                        Group {
                            if vm.isLoading {
                                HStack(spacing: 8) {
                                    ProgressView().tint(.white)
                                    Text("Calculando cotización...")
                                }
                            } else {
                                Text("Calcular precio de cotización")
                            }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(Color.bluePrimary)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                    .disabled(vm.isLoading || isLoadingTypes || selectedDevice == nil)
                    .opacity(selectedDevice == nil || isLoadingTypes ? 0.5 : 1)
                    .padding(.top, -28)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .frame(maxWidth: 1200)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Cotización")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadDeviceTypes()
        }
        .task(id: selectedTypeID) {
            guard let typeID = selectedTypeID else { return }
            await loadDevices(for: typeID)
        }
        .sheet(isPresented: $showResult) {
            if let quote = vm.lastQuote {
                QuoteResultView(
                    quote: quote,
                    viewModel: vm,
                    isAuthenticated: authVM.isAuthenticated
                ) {
                    showResult = false
                    vm.lastQuote = nil
                }
            }
        }
        .onChange(of: vm.lastQuote) { _, quote in
            if quote != nil { showResult = true }
        }
    }

    private var adaptiveColumns: [GridItem] {
        [GridItem(.adaptive(minimum: 130, maximum: 220), spacing: 14)]
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 34, weight: .bold))
            .tracking(-1)
            .foregroundColor(Color(hex: "1d1d1f"))
    }

    private func statusText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13))
            .foregroundColor(.textMuted)
    }

    private func selectionCard(
        title: String,
        subtitle: String?,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isSelected ? .bluePrimary : .textMain)
                    .lineSpacing(1)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(.textMuted)
                        .lineSpacing(1)
                }
            }
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .minimumScaleFactor(0.85)
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(isSelected ? Color.bluePrimary.opacity(0.04) : .white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.bluePrimary, lineWidth: isSelected ? 2 : 0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.black.opacity(0.1), lineWidth: isSelected ? 0 : 1)
            )
            .shadow(color: isSelected ? Color.bluePrimary.opacity(0.08) : .clear, radius: 6, x: 0, y: 0)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @MainActor
    private func loadDeviceTypes() async {
        isLoadingTypes = true
        catalogError = nil
        do {
            deviceTypes = try await QuotationService.shared.getDeviceTypes()
            selectedTypeID = deviceTypes.first?.id
        } catch {
            catalogError = error.localizedDescription
        }
        isLoadingTypes = false
    }

    @MainActor
    private func loadDevices(for typeID: String) async {
        isLoadingDevices = true
        devices = []
        selectedDeviceID = nil
        searchText = ""
        catalogError = nil
        do {
            let loadedDevices = try await QuotationService.shared.getDevices(deviceTypeId: typeID)
            guard !Task.isCancelled else { return }
            devices = loadedDevices
            selectedDeviceID = devices.first?.id
        } catch {
            guard !Task.isCancelled else { return }
            catalogError = error.localizedDescription
        }
        isLoadingDevices = false
    }

    private func submitQuote() {
        guard let device = selectedDevice,
              let deviceType = deviceTypes.first(where: { $0.id == selectedTypeID }) else {
            return
        }
        Task {
            await vm.createQuote(
                tenantId: tenantId,
                deviceType: (device.device_type_code ?? deviceType.code).lowercased(),
                brand: device.brand_name,
                model: device.model,
                year: device.year,
                condition: selectedCondition.rawValue,
                authenticated: authVM.isAuthenticated
            )
        }
    }
}
