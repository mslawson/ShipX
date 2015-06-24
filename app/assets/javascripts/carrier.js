// This is a manifest file that'll be compiled into application.js, hich will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, ib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced ere using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll ppear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.om/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery-ui
//= require jquery_ujs
//= require jquery.maskedinput
//= require turbolinks
//= require bootstrap
//= require underscore
//= require backbone
//= require backbone_rails_sync
//= require backbone_datalink
//= require backbone/ship_x
//= require jquery.datetimepicker

var appView = {
    titleEl: undefined,
    containerEl: undefined,
    actionsEl: undefined
};

$(document).ready(function () {
    initializeAppView();

    updatePageTitle(appPages.dashboard);
    updatePageAction(appPages.dashboard);
    updatePageView(appPages.dashboard);
    $('.page-link[data-page-type="dashboard"]').addClass("highlight");

    $("#menu-toggle").click(function (e) {
        e.preventDefault();
        $("#wrapper").toggleClass("toggled");
    });

    $('.page-link').click(function () {
        var pageType = $(this).data("page-type");
        if (typeof pageType === "string") {
            pageType = appPages[pageType];
            renderPage(pageType);
        }

        $('.page-link').removeClass("highlight");
        $(this).addClass("highlight");
    })
});

function renderPage(pageType, params) {
    updatePageTitle(pageType);
    updatePageAction(pageType);
    updatePageView(pageType, params);
}

function initializeAppView() {
    appView.titleEl = $("#page-title");
    appView.containerEl = $("#page-container");
    appView.actionsEl = $("#page-actions");
}

function updatePageTitle(pageType) {
    var pageTitle = typeof pageType === "object" && pageType != null ? pageType.title : undefined;
    if (typeof pageTitle === "string") {
        pageTitle = "Carrier//" + pageTitle;
    } else {
        pageTitle = "Carrier";
    }

    document.title = pageTitle;
    appView.titleEl.text(pageTitle);
}

function updatePageAction(pageType) {
    var actions = typeof pageType === "object" && pageType != null ? pageType.actions : undefined;
    if (Array.isArray(actions) && actions.length > 0) {
        var actionsHtml = "";
        $.each(actions, function (index, action) {
            actionsHtml += "<a class='btn btn-sm btn-primary page-action' data-action-index='" + index + "'>" + action["name"] + "</a>";
        });

        appView.actionsEl.html(actionsHtml);
        $(".page-action").click(function () {
            var index = $(this).data("action-index");
            var actionFn = actions[index]["actionFn"];
            if (typeof actionFn == "function") {
                actionFn();
            }
        });
    } else {
        appView.actionsEl.html("");
    }
}

function updatePageView(pageType, params) {
    var pageFn = typeof pageType === "object" && pageType != null ? pageType.pageFn : undefined;
    if (typeof pageFn === "function") {
        pageFn(params);
    } else {
        errorPage();
    }
}

var appPages = {
    dashboard: {
        title: "Dashboard",
        pageFn: dashboardPage
    },
    regions: {
        title: "Regions",
        pageFn: regionsPage,
        actions: [
            {
                name: 'Add Region',
                actionFn: addRegion
            }
        ]
    },
    tariffs: {
        title: "Default Pricing",
        pageFn: tariffsPage
    },
    lanes: {
        title: "Lanes",
        pageFn: lanesPage,
        actions: [
            {
                name: 'Add Lane',
                actionFn: addLane
            },
            {
                name: 'Upload Lane Pricing',
                actionFn: uploadPricing
            },
            {
                name: 'Upload Scheduled Pricing',
                actionFn: uploadScheduledPricing
            }
        ]
    },
    settings: {
        title: "Settings",
        pageFn: settingsPage
    }
}

function createLaneActivePricing(lanes) {
    if (lanes == null || lanes.length <= 0) {
        return [];
    }

    var activePricing = [];
    $.each(lanes, function (index, lane) {
        var pricing = {
            displayName: lane["name"],
            costFactor: lane["pricing"],
            minimumCharge: lane["minimum_charge"],
            laneId: lane["id"]
        };

        var scheduledPricings = parseArrayFromSOAPResponse(lane["lane_pricing"], "scheduled_price");
        var activeScheduledPricing = null;
        if (scheduledPricings != null && scheduledPricings.length > 0) {
            var today = new Date();
            $.each(scheduledPricings, function (index, scheduledPricing) {
                var startD = new Date(scheduledPricing["start_date"]);
                var endD = new Date(scheduledPricing["end_date"]);
                if (startD <= today && today <= endD) {
                    if (activeScheduledPricing == null) {
                        activeScheduledPricing = {};
                    }

                    activeScheduledPricing["costFactor"] = scheduledPricing["cost_factor"];
                    activeScheduledPricing["minimumCharge"] = scheduledPricing["minimum_charge"];
                    activeScheduledPricing["endDate"] = endD;
                    activeScheduledPricing["scheduledPricingId"] = scheduledPricing["pricing_scheduled_id"];
                }
            });
        }

        if (activeScheduledPricing != null) {
            pricing["costFactor"] = activeScheduledPricing["costFactor"];
            pricing["minimumCharge"] = activeScheduledPricing["minimumCharge"];
            pricing["endDate"] = activeScheduledPricing["endDate"];
            pricing["scheduledPricingId"] = activeScheduledPricing["scheduledPricingId"];
        } else {
            pricing["costFactor"] = lane["pricing"];
            pricing["minimumCharge"] = lane["minimum_charge"];
        }

        activePricing.push(pricing);
    });

    return activePricing;
}

function createDefaultActivityPricing(defaultPricing, pricingName) {
    return {
        displayName: pricingName,
        costFactor: defaultPricing["discount"],
        laneId: "default"
    };
}

function convertToActivePricingHtml(pricing) {
    var html = "<div class='col-md-12'><div class='active-pricing-tile' data-lane='" + pricing["laneId"] + "'>";
    html += "<div class='active-pricing-display-name'>" + pricing["displayName"] + "</div>"
    html += "<div class='active-pricing-details'><span class='active-pricing-discount'>" + pricing["costFactor"] + "%</span> discount";
    if (pricing["minimumCharge"] > 0) {
        html += " at a minimum charge of <span class='active-pricing-minimum-charge'>$" + pricing["minimumCharge"] + "</span>";
    }

    var disableAction = "";
    if (pricing["endDate"] != null) {
        html += " till <span class='active-pricing-end-date'>" + pricing["endDate"].toDateString() + "</span>";
        disableAction = "<a class='btn btn-sm btn-danger active-price-disable-action' data-lane='" + pricing["laneId"]
        + "' data-id='" + pricing["scheduledPricingId"] + "'>Disable</a>";
    }

    html += "</div>" + disableAction + "</div></div>";
    return html;
}

function dashboardPage() {
    var defaultPricingRequest = $.getJSON("/carrier/session/getdefaultpricing");
    var allLanesPricingRequest = $.getJSON("/carrier/session/lanes");
    $.when(defaultPricingRequest, allLanesPricingRequest).then(function (defaultPricingData, lanesData) {
        var lanes = parseArrayFromSOAPResponse(lanesData[0], "carrier_route");
        var lanesActivePricing = createLaneActivePricing(lanes);
        var restOfLanesPricingName = "Other Lanes";
        if (lanesActivePricing == null || lanesActivePricing.length <= 0) {
            restOfLanesPricingName = "All Lanes";
            lanesActivePricing = [];
        }

        var defaultActiveLanePricing = createDefaultActivityPricing(defaultPricingData[0], restOfLanesPricingName);
        if (defaultActiveLanePricing != null) {
            lanesActivePricing.push(defaultActiveLanePricing);
        }

        if (lanesActivePricing.length <= 0) {
            appView.containerEl.html("<div class='col-md-12 page-watermark'>No active pricing found for this carrier.</div>");
            return;
        }

        var activePricingHtml = "<h3 class='col-md-12'>Active Prices</h3>";
        $.each(lanesActivePricing, function (index, pricing) {
            activePricingHtml += convertToActivePricingHtml(pricing);
        });

        appView.containerEl.html(activePricingHtml);
        $(".active-pricing-tile").click(function () {
            var laneId = $(this).data('lane');
            if (laneId == null) {
                return;
            }

            if (laneId === "default") {
                renderPage(appPages["tariffs"], laneId);
            } else {
                renderPage(appPages["lanes"], laneId);
            }
        });

        $(".active-price-disable-action").click(function (event) {
            event.stopPropagation();
            event.stopImmediatePropagation();

            var pricingId = $(this).data("lane");
            var lanePricingId = $(this).data("id");

            showConfirmationDialog("Are you sure you want to disable this active pricing for the lane?", function (confirmed) {
                if (!confirmed) {
                    return;
                }

                $.getJSON("/carrier/session/deletelanepricing", {
                    id: lanePricingId,
                    pricingId: pricingId
                }, function (data) {
                    renderPage(appPages["dashboard"])
                }).fail(function (error) {
                    showErrorDialog("Failed to disable the active pricing for this lane.");
                });
            });
        })
    }, function (error) {
        appView.containerEl.html("<div class='col-md-12 page-watermark'>An error occurred while loading the dashboard for the carrier. Please try again.</div>");
    });
}

function lanesPage(laneId) {
    renderLanesPage("/carrier/session/lanes", null, laneId);
}

function renderLanesPage(lanesRequestUrl, lanesRequestData, laneId) {
    loadingPage();
    $.getJSON(lanesRequestUrl, lanesRequestData, function (data) {
        var lanes = parseArrayFromSOAPResponse(data, "carrier_route");
        if (Array.isArray(lanes) && lanes.length > 0) {
            var tableAction = "<a class='btn btn-sm btn-success table-action lane-details-action' data-index='routeId'>View</a>" +
                "<a class='btn btn-sm btn-success table-action lane-update-action' data-index='routeId'>Update</a>" +
                "<a class='btn btn-sm btn-danger table-action lane-delete-action' data-index='routeId'>Delete</a>";
            var table = "<table class='table'><tbody>";
            $.each(lanes, function (index, lane) {
                table += "<tr class='route-row' id='route-" + index + "'><td class='row-title'>" + lane["name"] + "</td><td class='align-right'>" + tableAction.replace(/'routeId'/g, index) + "</td></tr>";
            });

            table += "</tbody></table>";
            appView.containerEl.html("<div class='col-md-12'>" + table + "</div>");

            $("a.lane-details-action").click(function () {
                var target = $(this);
                var index = target.data("index");
                renderLaneDetails(index, target);
            });

            $("a.lane-delete-action").click(function () {
                var lane = lanes[$(this).data("index")];
                showConfirmationDialog("Are you sure you want to delete this lane", function (confirmed) {
                    if (confirmed) {
                        renderLanesPage("/carrier/session/deletelane", {id: lane["id"]});
                    }
                });
            });

            $("a.lane-update-action").click(function () {
                var lane = lanes[$(this).data("index")];
                showLaneUpdateDialog(lane);
            });

            if (laneId != null) {
                for (var i = 0; i < lanes.length; i++) {
                    var index = i;
                    if (laneId == lanes[index]["id"]) {
                        renderLaneDetails(index, $(appView.containerEl.find("tr.route-row")[index].firstChild));
                        break;
                    }
                }
            }

            function renderLaneDetails(index, target) {
                var allDetailsRow = $("tr.details-row");
                $.each(allDetailsRow, function (index, row) {
                    row.parentNode.removeChild(row);
                });

                var detailsRow = prepareLaneDetails(lanes[index]);
                target.closest("tr").after(detailsRow);
            }
        } else {
            appView.containerEl.html("<div class='col-md-12 page-watermark'>No lanes available.</div>");
        }
    }).fail(function (error) {
        appView.containerEl.html("<div class='col-md-12 page-watermark'>An error occurred while loading lanes for the carrier. Please try again.</div>");
    });
}

function tariffsPage() {
    renderTariffsPage("/carrier/session/getdefaultpricing", null);
}

function renderTariffsPage(tariffRequestUrl, tariffRequestData) {
    loadingPage();
    $.getJSON(tariffRequestUrl, tariffRequestData, function (tariff) {
        if (tariff != null) {
            var tariffTable = "<table class='table'><thead><tr><th>Tariff Name</th><th>Discount</th><th></th></tr></thead><tbody><tr>";
            tariffTable += "<td>" + tariff["tariff_name"] + "</td>";
            tariffTable += "<td>" + tariff["discount"] + "%</td>";
            tariffTable += "<td><a class='btn btn-sm btn-default tariff-update-action' style='float:right'>Update Discount</a></td>"
            tariffTable += "</tr></tbody></table>";
            appView.containerEl.html("<div class='col-md-12'>" + tariffTable + "</div>");

            $(".tariff-update-action").click(function () {
                showDialogForm("Update Default Pricing", "#update-default-pricing-form", function (form) {
                    var pricing = form.find("input[name=discount]").val();
                    renderTariffsPage("/carrier/session/updatedefaultpricing", {pricing: pricing});
                }, function (form) {
                    form.find("input[name=tariffName]").val(tariff["tariff_name"]);
                    form.find("input[name=discount]").val(tariff["discount"]);
                });
            });
        } else {
            appView.containerEl.html("<div class='col-md-12 page-watermark'>No default tariff found.</div>");
        }
    }).fail(function (error) {
        appView.containerEl.html("<div class='col-md-12 page-watermark'>An error occurred while loading the default pricing for the carrier. Please try again.</div>");
    });
}

function settingsPage() {
    appView.containerEl.html("<div class='col-md-12 page-watermark'>Coming soon</div>");
}

function loadingPage() {
    appView.containerEl.html("<div class='col-md-12 page-watermark'>Loading...</div>");
}

function errorPage() {
    appView.containerEl.html("<div class='col-md-12 page-watermark'>Oops! There was an error displaying this page.</div>");
}

function regionsPage() {
    renderRegionsPage("/carrier/session/regions", null);
}

function renderRegionsPage(regionsRequestUrl, regionsRequestData) {
    loadingPage();
    $.getJSON(regionsRequestUrl, regionsRequestData, function (data) {
        var regions = parseArrayFromSOAPResponse(data, "region");
        if (regions.length > 0) {
            var activeRegionsCount = 0;
            var activeRegionsTable = "<table class='table'><tbody>";
            var inactiveRegionsTable = "<table class='table'><tbody>";
            var regionAction = "<a class='btn btn-sm btn-default table-action region-details-action' data-index='regionId'>View</a>";
            regionAction += "<a class='btn btn-sm btn-danger table-action region-delete-action' data-index='regionId'>Delete</a>";

            $.each(regions, function (index, region) {
                var regionRow = "<tr class='region-row' id='region-" + index + "'><td>" + region["description"] + "</td><td class='align-right'>" + regionAction.replace(/'regionId'/g, index) + "</tr>";
                if (region["active"]) {
                    activeRegionsTable += regionRow;
                    activeRegionsCount++;
                } else {
                    inactiveRegionsTable += regionRow;
                }
            });

            activeRegionsTable += "</tbody></table>";
            inactiveRegionsTable += "</tbody></table>";
            appView.containerEl.html("");
            if (activeRegionsCount > 0) {
                appView.containerEl.append("<div class='col-md-12'><h3>Active Regions</h3>" + activeRegionsTable + "</div>");
            }

            if (activeRegionsCount < regions.length) {
                appView.containerEl.append("<div class='col-md-12'><h3>Inactive Regions</h3>" + inactiveRegionsTable + "</div>");
            }

            $("a.region-details-action").click(function () {
                var index = $(this).data("index");
                showRegionDetails(regions[index], $(this), function(region) {
                    regions[index] = region;
                });
            });

            $("a.region-delete-action").click(function () {
                var region = regions[$(this).data("index")];
                showConfirmationDialog("Are you sure you want to delete the region", function (confirmed) {
                    if (confirmed) {
                        renderRegionsPage("/carrier/session/deleteregion", {regionId: region["region_id"]});
                    }
                });
            });
        } else {
            appView.containerEl.html("<div class='col-md-12 page-watermark'>No regions available.</div>");
        }
    }).fail(function (error) {
        appView.containerEl.html("<div class='col-md-12 page-watermark'>An error occurred while loading regions for the carrier. Please try again.</div>");
    });
}

function prepareLaneDetails(lane) {
    var laneDetailsRow = $(document.createElement("tr"));
    laneDetailsRow.attr("class", "details-row");
    var detailsHtml = prepareRegionDetails(lane["starting_region"], "Origin");
    detailsHtml += prepareRegionDetails(lane["ending_region"], "Destination");

    var pricingTableHeaders = ["Cost Factor", "Minimum Charge"];
    var pricingTableColumns = [
        formatPricingAttribute(lane["pricing"], lane["pricing_use_default"]),
        formatPricingAttribute(lane["minimum_charge"], lane["minimum_charge_use_default"])
    ];

    var pricingHtml = "<h4>Lane Pricing</h4>";
    pricingHtml += "<table class='table table-bordered'><thead><tr>";
    $.each(pricingTableHeaders, function (index, header) {
        pricingHtml += "<th>" + header + "</th>";
    });

    pricingHtml += "</tr></thead><tbody><tr>";
    $.each(pricingTableColumns, function (index, column) {
        pricingHtml += "<td>" + column + "</td>";
    });

    pricingHtml += "</tr></tbody></table>";
    detailsHtml += pricingHtml;
    laneDetailsRow.html("<td colspan='2'>" + detailsHtml + "</td>");
    var scheduledPricing = parseArrayFromSOAPResponse(lane["lane_pricing"], "scheduled_price");
    renderScheduledPricing(lane, laneDetailsRow, scheduledPricing);
    return laneDetailsRow;
}

function renderScheduledPricing(lane, laneDetailsRow, scheduledPricing) {
    var scheduleDetailsRow = $(laneDetailsRow.children()[0]).find("div.lane-schedule-pricing-details");
    if (scheduleDetailsRow != null && scheduleDetailsRow.length > 0) {
        scheduleDetailsRow = scheduleDetailsRow[0];
    } else {
        scheduleDetailsRow = document.createElement("div");
        $(scheduleDetailsRow).addClass("lane-schedule-pricing-details");
        $(scheduleDetailsRow).appendTo($(laneDetailsRow.children()[0]));
    }

    $(scheduleDetailsRow).html("");
    var schedulePricingActionsHtml = "<a class='btn btn-xs btn-success lane-schedule-pricing-update-action lane-schedule-pricing-action' data-index='index'>Update</a>" +
        "<a class='btn btn-xs btn-danger lane-schedule-pricing-delete-action lane-schedule-pricing-action' data-index='index'>Delete</a>";

    var scheduledPricingHtml = "<h4>Scheduled Pricing <a class='pull-right btn btn-xs btn-success lane-schedule-pricing-add-action'><span class='glyphicon glyphicon-plus' aria-hidden='true'></a></h4>";
    if (scheduledPricing.length > 0) {
        var tableHeaders = ["Start Date", "Cost Factor", "Minimum Charge", "End Date", "Restore Cost Factor", "Restore Minimum Charge", "Actions"];
        var tableRows = [];
        $.each(scheduledPricing, function (index, pricing) {
            var tableColumns = [];
            tableColumns.push(formatDateString(pricing["start_date"]));
            tableColumns.push(formatPricingAttribute(pricing["cost_factor"], pricing["cost_factor_use_default"]));
            tableColumns.push(formatPricingAttribute(pricing["minimum_charge"], pricing["minimum_charge_use_default"]));
            tableColumns.push(formatDateString(pricing["end_date"]));
            tableColumns.push(formatPricingAttribute(pricing["restore_cost_factor"], pricing["restore_cost_factor_use_default"]));
            tableColumns.push(formatPricingAttribute(pricing["restore_minimum_charge"], pricing["restore_minimum_charge_use_default"]));
            tableColumns.push(schedulePricingActionsHtml.replace(/'index'/g, index));

            tableRows.push(tableColumns);
        });

        scheduledPricingHtml += "<table class='table table-bordered'><thead><tr>";
        $.each(tableHeaders, function (index, header) {
            scheduledPricingHtml += "<th>" + header + "</th>";
        });

        scheduledPricingHtml += "</tr></thead><tbody>";
        $.each(tableRows, function (index, row) {
            scheduledPricingHtml += "<tr>";
            $.each(row, function (index, column) {
                scheduledPricingHtml += "<td>" + column + "</td>";
            });

            scheduledPricingHtml += "</tr>";
        });

        scheduledPricingHtml += "</tbody></table>";
    } else {
        scheduledPricingHtml += "Nothing";
    }

    $(scheduleDetailsRow).html(scheduledPricingHtml);
    laneDetailsRow.find(".lane-schedule-pricing-add-action").click(function () {
        addLaneScheduledPricing(lane, function (updatedScheduledPricing) {
            renderScheduledPricing(lane, laneDetailsRow, updatedScheduledPricing);
        });
    });

    laneDetailsRow.find(".lane-schedule-pricing-update-action").click(function () {
        var schedulePricing = scheduledPricing[$(this).data("index")];
        updateLaneScheduledPricing(lane, schedulePricing, function (updatedScheduledPricing) {
            renderScheduledPricing(lane, laneDetailsRow, updatedScheduledPricing);
        });
    });

    laneDetailsRow.find(".lane-schedule-pricing-delete-action").click(function () {
        var schedulePricing = scheduledPricing[$(this).data("index")];
        deleteLaneScheduledPricing(lane, schedulePricing, function (updatedScheduledPricing) {
            renderScheduledPricing(lane, laneDetailsRow, updatedScheduledPricing);
        });
    });
}

function addLaneScheduledPricing(lane, updateCallback) {
    showDialogForm("Add Lane Scheduled Pricing", "#add-lane-scheduled-pricing-form", function (form) {
        var costFactor = form.find("input[name=costFactor]").val();
        var costFactorUseDefault = form.find("input[name=costFactorUseDefault]").is(':checked');
        var restoreCostFactor = form.find("input[name=restoreCostFactor]").val();
        var restoreCostFactorUseDefault = form.find("input[name=restoreCostFactorUseDefault]").is(':checked');
        var minimumCharge = form.find("input[name=minimumCharge]").val();
        var minimumChargeUseDefault = form.find("input[name=minimumChargeUseDefault]").is(':checked');
        var restoreMinimumCharge = form.find("input[name=restoreMinimumCharge]").val();
        var restoreMinimumChargeUseDefault = form.find("input[name=restoreMinimumChargeUseDefault]").is(':checked');
        updateAndRenderScheduledPricing("/carrier/session/insertlanepricing", {
            pricingId: lane["id"],
            startDate: form.find("input[name=startDate]").val(),
            endDate: form.find("input[name=endDate]").val(),
            costFactor: costFactor,
            costFactorUseDefault: costFactorUseDefault,
            restoreCostFactor: restoreCostFactor,
            restoreCostFactorUseDefault: restoreCostFactorUseDefault,
            minimumCharge: minimumCharge,
            minimumChargeUseDefault: minimumChargeUseDefault,
            restoreMinimumCharge: restoreMinimumCharge,
            restoreMinimumChargeUseDefault: restoreMinimumChargeUseDefault
        }, "Failed to add a new scheduled pricing for this lane", updateCallback);
    }, function (form) {
        var costFactor = form.find("input[name=costFactor]");
        form.find("input[name=costFactorUseDefault]").change(function () {
            var isChecked = $(this).is(":checked");
            if (isChecked) {
                costFactor.prop('disabled', true);
                costFactor.val(lane["pricing"]);
            } else {
                costFactor.prop('disabled', false);
                costFactor.val("");
                costFactor.focus();
            }
        });

        var restoreCostFactor = form.find("input[name=restoreCostFactor]");
        form.find("input[name=restoreCostFactorUseDefault]").change(function () {
            var isChecked = $(this).is(":checked");
            if (isChecked) {
                restoreCostFactor.prop('disabled', true);
                restoreCostFactor.val(lane["pricing"]);
            } else {
                restoreCostFactor.prop('disabled', false);
                restoreCostFactor.val("");
                restoreCostFactor.focus();
            }
        });

        convertToDatePicker(form.find("input[name=startDate]"));
        convertToDatePicker(form.find("input[name=endDate]"));
    });
}

function updateLaneScheduledPricing(lane, scheduledPricing, updateCallback) {
    showDialogForm("Update Lane Scheduled Pricing", "#add-lane-scheduled-pricing-form", function (form) {
        var costFactor = form.find("input[name=costFactor]").val();
        var costFactorUseDefault = form.find("input[name=costFactorUseDefault]").is(':checked');
        var restoreCostFactor = form.find("input[name=restoreCostFactor]").val();
        var restoreCostFactorUseDefault = form.find("input[name=restoreCostFactorUseDefault]").is(':checked');
        var minimumCharge = form.find("input[name=minimumCharge]").val();
        var minimumChargeUseDefault = form.find("input[name=minimumChargeUseDefault]").is(':checked');
        var restoreMinimumCharge = form.find("input[name=restoreMinimumCharge]").val();
        var restoreMinimumChargeUseDefault = form.find("input[name=restoreMinimumChargeUseDefault]").is(':checked');
        updateAndRenderScheduledPricing("/carrier/session/updatelanepricing", {
            scheduledPricingId: scheduledPricing["pricing_scheduled_id"],
            pricingId: lane["id"],
            startDate: form.find("input[name=startDate]").val(),
            endDate: form.find("input[name=endDate]").val(),
            costFactor: costFactor,
            costFactorUseDefault: costFactorUseDefault,
            restoreCostFactor: restoreCostFactor,
            restoreCostFactorUseDefault: restoreCostFactorUseDefault,
            minimumCharge: minimumCharge,
            minimumChargeUseDefault: minimumChargeUseDefault,
            restoreMinimumCharge: restoreMinimumCharge,
            restoreMinimumChargeUseDefault: restoreMinimumChargeUseDefault
        }, "Failed to add a new scheduled pricing for this lane", updateCallback);
    }, function (form) {
        form.find("input[name=startDate]").val(formatDateString(scheduledPricing["start_date"]));
        form.find("input[name=endDate]").val(formatDateString(scheduledPricing["end_date"]));
        form.find("input[name=costFactor]").val(scheduledPricing["cost_factor"]);
        form.find("input[name=costFactorUseDefault]").prop('checked', scheduledPricing["cost_factor_use_default"]);
        form.find("input[name=restoreCostFactor]").val(scheduledPricing["restore_cost_factor"]);
        form.find("input[name=restoreCostFactorUseDefault]").prop('checked', scheduledPricing["restore_cost_factor_use_default"]);
        form.find("input[name=minimumCharge]").val(scheduledPricing["minimum_charge"]);
        form.find("input[name=minimumChargeUseDefault]").prop('checked', scheduledPricing["minimum_charge_use_default"]);
        form.find("input[name=restoreMinimumCharge]").val(scheduledPricing["restore_minimum_charge"]);
        form.find("input[name=restoreMinimumChargeUseDefault]").prop('checked', scheduledPricing["restore_minimum_charge_use_default"]);

        var costFactor = form.find("input[name=costFactor]");
        form.find("input[name=costFactorUseDefault]").change(function () {
            var isChecked = $(this).is(":checked");
            if (isChecked) {
                costFactor.prop('disabled', true);
                costFactor.val(lane["pricing"]);
            } else {
                costFactor.prop('disabled', false);
                costFactor.val(scheduledPricing["cost_factor"]);
                costFactor.focus();
            }
        });

        var restoreCostFactor = form.find("input[name=restoreCostFactor]");
        form.find("input[name=restoreCostFactorUseDefault]").change(function () {
            var isChecked = $(this).is(":checked");
            if (isChecked) {
                restoreCostFactor.prop('disabled', true);
                restoreCostFactor.val(lane["pricing"]);
            } else {
                restoreCostFactor.prop('disabled', false);
                restoreCostFactor.val(scheduledPricing["restore_cost_factor"]);
                restoreCostFactor.focus();
            }
        });

        convertToDatePicker(form.find("input[name=startDate]"));
        convertToDatePicker(form.find("input[name=endDate]"));
    });
}

function deleteLaneScheduledPricing(lane, scheduledPricing, updateCallback) {
    showConfirmationDialog("Are you sure you want to delete this scheduled pricing for the lane?", function (confirmed) {
        if (!confirmed) {
            return;
        }

        updateAndRenderScheduledPricing("/carrier/session/deletelanepricing", {
            id: scheduledPricing["pricing_scheduled_id"],
            pricingId: lane["id"]
        }, "Failed to delete the scheduled pricing for this lane", updateCallback);
    });
}

function updateAndRenderScheduledPricing(udpateRequestUrl, updateRequestData, failureMessage, updateCallback) {
    $.getJSON(udpateRequestUrl, updateRequestData, function (data) {
        var scheduledPricing = parseArrayFromSOAPResponse(data, "scheduled_price");
        updateCallback(scheduledPricing)
    }).fail(function (error) {
        showErrorDialog(failureMessage);
    });
}

function formatPricingAttribute(value, useDefault) {
    var attrLabelClass = useDefault ? "label-success" : "label-default";
    var attrLabelTitle = useDefault ? "Use Default: True" : "Use Default: False";
    var attrLabel = "<span class='pull-right label " + attrLabelClass + "' title='" + attrLabelTitle + "'>Use Default</span>"
    return value + attrLabel;
}

function formatDateString(dateString) {
    var date = new Date(dateString);
    return date.toISOString().slice(0, 10);
}

function showRegionDetails(region, regionRow, updateCallback) {
    var allDetailsRow = $("tr.details-row");
    $.each(allDetailsRow, function (index, row) {
        row.parentNode.removeChild(row);
    });

    var detailsRow = prepareRegionDetailsRow(region);
    regionRow.closest("tr").after(detailsRow);

    $("a.region-entity-add-action").click(function () {
        var addEntityType = $(this).data("entityType");
        if (addEntityType === "state") {
            showDialogForm("Add Region State", "#add-region-state-form", function (form) {
                var state = form.find("input[name=state]").val();
                var excluded = form.find("input[name=excluded]").is(':checked');
                $.getJSON("/carrier/session/insertregionstate", {
                    regionId: region["region_id"],
                    state: state,
                    excluded: excluded
                }, function (data) {
                    if (typeof data === "object" && data !== null) {
                        showRegionDetails(data, regionRow, updateCallback);
                        updateCallback(data);
                    }
                });
            });
        } else if (addEntityType === "zip-code") {
            showDialogForm("Add Region Zip", "#add-region-zip-form", function (form) {
                var zipCode = form.find("input[name=zipCode]").val();
                var excluded = form.find("input[name=excluded]").is(':checked');
                $.getJSON("/carrier/session/insertregionzip", {
                    regionId: region["region_id"],
                    zipCode: zipCode,
                    excluded: excluded
                }, function (data) {
                    if (typeof data === "object" && data !== null) {
                        showRegionDetails(data, regionRow, updateCallback);
                        updateCallback(data);
                    }
                });
            })
        } else if (addEntityType === "zip-range") {
            showDialogForm("Add Region Zip Range", "#add-region-zip-range-form", function (form) {
                var startingZipCode = form.find("input[name=startingZipCode]").val();
                var endingZipCode = form.find("input[name=endingZipCode]").val();
                var excluded = form.find("input[name=excluded]").is(':checked');
                $.getJSON("/carrier/session/insertregionziprange", {
                    regionId: region["region_id"],
                    startingZipCode: startingZipCode,
                    endingZipCode: endingZipCode,
                    excluded: excluded
                }, function (data) {
                    if (typeof data === "object" && data !== null) {
                        showRegionDetails(data, regionRow, updateCallback);
                        updateCallback(data);
                    }
                });
            })
        }
    });

    $(".region-entity-delete-action").click(function () {
        var deleteEntityType = $(this).data("entityType");
        var regionEntityIndex = $(this).data("index");
        if (deleteEntityType === "state") {
            showConfirmationDialog("Are you sure you want to delete this region state?", function (confirmed) {
                if (!confirmed) {
                    return;
                }

                var regionStates = parseArrayFromSOAPResponse(region["states"], "string");
                var state = regionStates[regionEntityIndex];
                var excluded = false;
                $.getJSON("/carrier/session/deleteregionstate", {
                    regionId: region["region_id"],
                    state: state,
                    excluded: excluded
                }, function (data) {
                    if (typeof data === "object" && data !== null) {
                        showRegionDetails(data, regionRow, updateCallback);
                        updateCallback(data);
                    }
                });
            });
        } else if (deleteEntityType === "zip-code") {
            showConfirmationDialog("Are you sure you want to delete this region zip?", function (confirmed) {
                if (!confirmed) {
                    return;
                }

                var regionZipCodes = parseArrayFromSOAPResponse(region["zip_codes"], "string");
                var zipCode = regionZipCodes[regionEntityIndex];
                var excluded = false;
                $.getJSON("/carrier/session/deleteregionzip", {
                    regionId: region["region_id"],
                    zipCode: zipCode,
                    excluded: excluded
                }, function (data) {
                    if (typeof data === "object" && data !== null) {
                        showRegionDetails(data, regionRow, updateCallback);
                        updateCallback(data);
                    }
                });
            });
        } else if (deleteEntityType === "zip-range") {
            showConfirmationDialog("Are you sure you want to delete this region zip range?", function (confirmed) {
                if (!confirmed) {
                    return;
                }

                var regionZipRanges = parseArrayFromSOAPResponse(region["zip_ranges"], "zip_range");
                var zipRange = regionZipRanges[regionEntityIndex];
                var excluded = false;
                $.getJSON("/carrier/session/deleteregionziprange", {
                    regionId: region["region_id"],
                    startingZipCode: zipRange["starting_zip"],
                    endingZipCode: zipRange["ending_zip"],
                    excluded: excluded
                }, function (data) {
                    if (typeof data === "object" && data !== null) {
                        showRegionDetails(data, regionRow, updateCallback);
                        updateCallback(data);
                    }
                });
            });
        }
    });
}

function prepareRegionDetailsRow(region) {
    var regionDetails = $(document.createElement("tr"));
    regionDetails.attr("class", "details-row");

    var regionTableHeaders = [];
    var regionTableColumns = [];

    var statesColumn = prepareRegionEntityDetailsColumn(region, "states", "state", "string");
    if (typeof statesColumn === "string" && statesColumn.length > 0) {
        regionTableHeaders[regionTableHeaders.length] = "State <a class='pull-right btn btn-xs btn-success region-entity-add-action' data-entity-type='state'><span class='glyphicon glyphicon-plus' aria-hidden='true'></a>";
        regionTableColumns[regionTableColumns.length] = statesColumn;
    }

    var zipCodesColumn = prepareRegionEntityDetailsColumn(region, "zip_codes", "zip-code", "string");
    if (typeof zipCodesColumn === "string" && zipCodesColumn.length > 0) {
        regionTableHeaders[regionTableHeaders.length] = "Zip Codes <a class='pull-right btn btn-xs btn-success region-entity-add-action' data-entity-type='zip-code'><span class='glyphicon glyphicon-plus' aria-hidden='true'></a>";
        regionTableColumns[regionTableColumns.length] = zipCodesColumn;
    }

    var zipRangesColumn = prepareRegionZipRangeDetailsColumn(region);
    if (typeof zipRangesColumn === "string" && zipRangesColumn.length > 0) {
        regionTableHeaders[regionTableHeaders.length] = "Zip Ranges <a class='pull-right btn btn-xs btn-success region-entity-add-action' data-entity-type='zip-range'><span class='glyphicon glyphicon-plus' aria-hidden='true'></a>";
        regionTableColumns[regionTableColumns.length] = zipRangesColumn;
    }

    var detailsHtml = "";
    detailsHtml += "<table class='table table-bordered table-details'><thead><tr>";
    $.each(regionTableHeaders, function (index, header) {
        detailsHtml += "<th>" + header + "</th>";
    });

    detailsHtml += "</tr></thead><tbody><tr>";
    $.each(regionTableColumns, function (index, column) {
        detailsHtml += "<td>" + column + "</td>";
    });

    detailsHtml += "</tr></tbody></table>";
    regionDetails.html("<td colspan='2'>" + detailsHtml + "</td>");
    return regionDetails;
}

function prepareRegionEntityDetailsColumn(region, entitySelector, entityType, entityDataType) {
    if (typeof region[entitySelector] === "object" && region[entitySelector] !== null) {
        var deleteAction = "<a class='region-entity-delete-action' data-entity-type='" + entityType + "' data-index='regionEntityId'><span class='glyphicon glyphicon-remove' aria-hidden='true'/></a>";
        var allEntities = parseArrayFromSOAPResponse(region[entitySelector], entityDataType);
        if (allEntities.length > 0) {
            var entityColumnHtml = "";
            $.each(allEntities, function (index, value) {
                entityColumnHtml += "<span class='label label-primary label-region-entity'><a target='_blank' href='https://www.google.com/maps/place/" + value + "'>" + value + "</a>" + deleteAction.replace(/'regionEntityId'/g, index) + "</span>";
            });

            return entityColumnHtml;
        }
    }

    return "Nothing";
}

function prepareRegionZipRangeDetailsColumn(region) {
    var entitySelector = "zip_ranges";
    var entityType = "zip_range";
    if (typeof region[entitySelector] === "object" && region[entitySelector] !== null) {
        var deleteAction = "<a class='region-entity-delete-action' data-entity-type='zip-range' data-index='regionEntityId'><span class='glyphicon glyphicon-remove' aria-hidden='true'/></a>";
        var allEntities = parseArrayFromSOAPResponse(region[entitySelector], entityType);
        if (allEntities.length > 0) {
            var entityColumnHtml = "";
            $.each(allEntities, function (index, value) {
                entityColumnHtml += "<span class='label label-primary label-region-entity'><a target='_blank' href='https://www.google.com/maps/place/" + value["starting_zip"] + "'>" + value["starting_zip"] + "</a> - <a target='_blank' href='https://www.google.com/maps/place/" + value["ending_zip"] + "'>" + value["ending_zip"] + "</a>" + deleteAction.replace(/'regionEntityId'/g, index) + "</span>";
            });

            return entityColumnHtml;
        }
    }

    return "Nothing";
}

function prepareRegionDetails(region, title) {
    var html = "";
    if (typeof title === "string") {
        html += "<h4>" + title + "</h4>";
    }

    var regionTableHeaders = [];
    var regionTableColumns = [];
    if (typeof region["states"] === "object" && region["states"] !== null) {
        regionTableHeaders[regionTableHeaders.length] = "States";
        var columnHtmls = [];
        var allStates = region["states"]["string"];
        if (Array.isArray(allStates)) {
            $.each(allStates, function (index, value) {
                columnHtmls[columnHtmls.length] = "<a target='_blank' href='https://www.google.com/maps/place/" + value + "'>" + value + "</a>";
            });
        } else if (typeof allStates === "string") {
            var value = allStates;
            columnHtmls[columnHtmls.length] = "<a target='_blank' href='https://www.google.com/maps/place/" + value + "'>" + value + "</a>";
        }

        regionTableColumns[regionTableColumns.length] = columnHtmls.join(", ");
    }

    if (typeof region["zip_codes"] === "object" && region["zip_codes"] !== null) {
        regionTableHeaders[regionTableHeaders.length] = "Zip Codes";
        var columnHtmls = [];
        var allZipCodes = region["zip_codes"]["string"];
        if (Array.isArray(allZipCodes)) {
            $.each(allZipCodes, function (index, value) {
                columnHtmls[columnHtmls.length] = "<a target='_blank' href='https://www.google.com/maps/place/" + value + "'>" + value + "</a>";
            });
        } else if (typeof allZipCodes === "string") {
            var value = allZipCodes;
            columnHtmls[columnHtmls.length] = "<a target='_blank' href='https://www.google.com/maps/place/" + value + "'>" + value + "</a>";
        }

        regionTableColumns[regionTableColumns.length] = columnHtmls.join(", ");
    }

    if (typeof region["zip_ranges"] === "object" && region["zip_ranges"] !== null) {
        regionTableHeaders[regionTableHeaders.length] = "Zip Ranges";
        var columnHtmls = [];
        var allZipRanges = region["zip_ranges"]["zip_range"];
        if (Array.isArray(allZipRanges)) {
            $.each(allZipRanges, function (index, value) {
                columnHtmls[columnHtmls.length] = "<a target='_blank' href='https://www.google.com/maps/place/" + value["starting_zip"] + "'>" + value["starting_zip"] + "</a> - <a target='_blank' href='https://www.google.com/maps/place/" + value["ending_zip"] + "'>" + value["ending_zip"] + "</a>";
            });
        } else if (typeof allZipRanges === "object") {
            var value = allZipRanges;
            columnHtmls[columnHtmls.length] = "<a target='_blank' href='https://www.google.com/maps/place/" + value["starting_zip"] + "'>" + value["starting_zip"] + "</a> - <a target='_blank' href='https://www.google.com/maps/place/" + value["ending_zip"] + "'>" + value["ending_zip"] + "</a>";
        }

        regionTableColumns[regionTableColumns.length] = columnHtmls.join(", ");
    }

    if (typeof region["exclusion_zip_codes"] === "object" && region["exclusion_zip_codes"] !== null) {
        regionTableHeaders[regionTableHeaders.length] = "Exclusion Zip Codes";
        var columnHtmls = [];
        var allExcludedZipCodes = region["exclusion_zip_codes"]["string"];
        if (Array.isArray(allExcludedZipCodes)) {
            $.each(allExcludedZipCodes, function (index, value) {
                columnHtmls[columnHtmls.length] = "<a target='_blank' href='https://www.google.com/maps/place/" + value + "'>" + value + "</a>";
            });
        } else if (typeof allExcludedZipCodes === "string") {
            var value = allExcludedZipCodes;
            columnHtmls[columnHtmls.length] = "<a target='_blank' href='https://www.google.com/maps/place/" + value + "'>" + value + "</a>";
        }

        regionTableColumns[regionTableColumns.length] = columnHtmls.join(", ");
    }

    html += "<table class='table table-bordered'><thead><tr>";
    $.each(regionTableHeaders, function(index, header) {
        html += "<th>" + header + "</th>";
    });

    html += "</tr></thead><tbody><tr>";
    $.each(regionTableColumns, function(index, column) {
        html += "<td>" + column + "</td>";
    });

    html += "</tr></tbody></table>";
    return html;
}

function addRegion() {
    showDialogForm("Add Region", "#add-region-form", function (form) {
        var regionName = form.find("input[name=name]").val();
        var isActive = form.find("input[name=active]").is(':checked');
        renderRegionsPage("/carrier/session/createregion", {regionName: regionName, active: isActive});
    });
}

function addLane() {
    $.getJSON('/carrier/session/regions', null, function (data) {
        var regions = parseArrayFromSOAPResponse(data, "region");
        if (regions.length > 0) {
            showDialogForm("Add Lane", "#add-lane-form", function (form) {
                var destinationId = form.find("select[name=destination] option:selected").val();
                var originId = form.find("select[name=origin] option:selected").val();
                var costFactor = form.find("input[name=costFactor]").val();
                var costFactorUseDefault = form.find("input[name=costFactorUseDefault]").is(':checked');
                var minimumCharge = form.find("input[name=minimumCharge]").val();
                var minimumChargeUseDefault = form.find("input[name=minimumChargeUseDefault]").is(':checked');
                renderLanesPage("/carrier/session/createlane", {
                    originRegionId: originId,
                    destinationRegionId: destinationId,
                    costFactor: costFactor,
                    costFactorUseDefault: costFactorUseDefault,
                    minimumCharge: minimumCharge,
                    minimumChargeUseDefault: minimumChargeUseDefault
                });
            }, function (form) {
                var originSelectEl = form.find("select[name=origin]");
                var destinationSelectEl = form.find("select[name=destination]");
                $.each(regions, function (index, region) {
                    originSelectEl.append(new Option(region["description"], region["region_id"]));
                    destinationSelectEl.append(new Option(region["description"], region["region_id"]));
                });

                var costFactorInput = form.find("input[name=costFactor]");
                form.find("input[name=costFactorUseDefault]").change(function () {
                    var isChecked = $(this).is(":checked");
                    if (isChecked) {
                        $.getJSON("/carrier/session/getdefaultpricing", null, function (data) {
                            costFactorInput.prop('disabled', true);
                            costFactorInput.val(data["discount"]);
                        }).fail(function (error) {
                            showErrorDialog("Failed to fetch default pricing configuration for the carrier.");
                            costFactorInput.prop('disabled', true);
                        });
                    } else {
                        costFactorInput.prop('disabled', false);
                        costFactorInput.val("");
                        costFactorInput.focus();
                    }
                });
            });
        } else {
            showErrorDialog("No regions added. Please add a region before creating a lane.");
        }
    }).fail(function (error) {
        showErrorDialog("No regions added. Please add a region before creating a lane.");
    });
}

function uploadPricing() {
    showFileUploadDialogForm("Upload Lane Pricing", "/carrier/session/uploadpricing", function (complete) {
        renderLanesPage("/carrier/session/lanes", null, null);
    });
}

function uploadScheduledPricing() {
    showFileUploadDialogForm("Upload Scheduled Pricing", "/carrier/session/uploadschedulepricing", function (complete) {
        renderLanesPage("/carrier/session/lanes", null, null);
    });
}

function showLaneUpdateDialog(lane) {
    $.getJSON('/carrier/session/regions', null, function (data) {
        var regions = parseArrayFromSOAPResponse(data, "region");
        if (regions.length > 0) {
            showDialogForm("Update Lane", "#add-lane-form", function (form) {
                var destinationId = form.find("select[name=destination] option:selected").val();
                var originId = form.find("select[name=origin] option:selected").val();
                var costFactor = form.find("input[name=costFactor]").val();
                var costFactorUseDefault = form.find("input[name=costFactorUseDefault]").is(':checked');
                var minimumCharge = form.find("input[name=minimumCharge]").val();
                var minimumChargeUseDefault = form.find("input[name=minimumChargeUseDefault]").is(':checked');
                renderLanesPage("/carrier/session/updatelane", {
                    pricingId: lane.id,
                    originRegionId: originId,
                    destinationRegionId: destinationId,
                    costFactor: costFactor,
                    costFactorUseDefault: costFactorUseDefault,
                    minimumCharge: minimumCharge,
                    minimumChargeUseDefault: minimumChargeUseDefault
                });
            }, function (form) {
                var originSelectEl = form.find("select[name=origin]");
                var destinationSelectEl = form.find("select[name=destination]");
                $.each(regions, function (index, region) {
                    originSelectEl.append(new Option(region["description"], region["region_id"]));
                    destinationSelectEl.append(new Option(region["description"], region["region_id"]));
                });

                originSelectEl.find("option[value='" + lane["starting_region"]["region_id"] + "']").attr('selected', 'selected');
                destinationSelectEl.find("option[value='" + lane["ending_region"]["region_id"] + "']").attr('selected', 'selected');

                form.find("input[name=costFactor]").val(lane["pricing"]);
                form.find("input[name=costFactorUseDefault]").prop('checked', lane["pricing_use_default"]);
                form.find("input[name=minimumCharge]").val(lane["minimum_charge"]);
                form.find("input[name=minimumChargeUseDefault]").prop('checked', lane["minimum_charge_use_default"]);

                var costFactorInput = form.find("input[name=costFactor]");
                form.find("input[name=costFactorUseDefault]").change(function () {
                    var isChecked = $(this).is(":checked");
                    if (isChecked) {
                        $.getJSON("/carrier/session/getdefaultpricing", null, function (data) {
                            costFactorInput.prop('disabled', true);
                            costFactorInput.val(data["discount"]);
                        }).fail(function (error) {
                            showErrorDialog("Failed to fetch default pricing configuration for the carrier.");
                            costFactorInput.prop('disabled', true);
                            costFactorInput.val(lane["pricing"]);
                        });
                    } else {
                        costFactorInput.prop('disabled', false);
                        costFactorInput.val(lane["pricing"]);
                        costFactorInput.focus();
                    }
                });
            });
        } else {
            showErrorDialog("No regions added. Please add a region before updating this lane.");
        }
    }).fail(function (error) {
        showErrorDialog("No regions added. Please add a region before updating this lane.");
    });
}

function parseArrayFromSOAPResponse(response, arrayName) {
    var array = response != null && typeof response === "object" ? response[arrayName] : null;
    if (Array.isArray(array)) {
        return array;
    } else if (array) {
        return [array];
    }

    return [];
}

function showDialogForm(formTitle, formTemplateSelector, formSubmitCallback, formReadyCallback, isSticky) {
    var modalEl = $("#modalDialogForm").clone();
    modalEl.find('#modalDialogTitle').html(formTitle);

    var formEl = $(formTemplateSelector).clone();
    formEl.removeClass("html-template");
    formEl.submit(function (event) {
        event.preventDefault();
        modalEl.modal("hide");
        formSubmitCallback(formEl);
    });

    modalEl.find('#modalDialogBody').html("").append(formEl);
    modalEl.find("#modalDialogSubmit").click(function () {
        formEl.submit();
    });

    modalEl.modal("show");
    if (typeof formReadyCallback === 'function') {
        formReadyCallback(formEl);
    }
}

function showFileUploadDialogForm(formTitle, uploadUrl, uploadCompleteCallback) {
    var modalEl = $("#modalDialogForm").clone();
    modalEl.find('#modalDialogTitle').html(formTitle);

    var formEl = $("#upload-file-form").clone();
    formEl.removeClass("html-template");
    formEl.submit(function (event) {
        event.preventDefault();

        var files = formEl.find("input[name='file']")[0].files;
        if (files.length > 0) {
            uploadFile(files[0], uploadUrl, function (progress) {
                console.log("File upload progress: " + progress);
            }, function (complete) {
                modalEl.modal("hide");
                if (typeof uploadCompleteCallback === "function") {
                    uploadCompleteCallback(complete);
                }
            });
        }
    });

    modalEl.find('#modalDialogBody').html("").append(formEl);
    var submitBtn = modalEl.find("#modalDialogSubmit")[0];
    $(submitBtn).click(function () {
        formEl.submit();
    });

    $(submitBtn).val("Upload File");
    modalEl.modal("show");
}

function showConfirmationDialog(confirmationMessage, callback) {
    var modalEl = $("#deleteConfirmDialogForm").clone();
    modalEl.find('#deleteConfirmMessage').html(confirmationMessage);
    modalEl.find("#deleteConfirmBtn").click(function () {
        callback(true);
        modalEl.modal("hide");
    });

    modalEl.modal("show");
}

function showErrorDialog(errorMessage) {
    var modalEl = $("#errorDialogForm").clone();
    modalEl.find('#errorMessage').html(errorMessage);
    modalEl.modal("show");
}

function convertToDatePicker(input) {
    input.datetimepicker({
        timepicker: false,
        format: "Y-m-d"
    });
}

function uploadFile(file, url, progressCallback, completeCallback) {
    var xhr = new XMLHttpRequest();
    xhr.addEventListener('progress', function (e) {
        var done = e.position || e.loaded, total = e.totalSize || e.total;
        var progress = Math.floor(done / total * 1000) / 10;
        if (typeof progressCallback === "function") {
            progressCallback(progress);
        }
    }, false);
    if (xhr.upload) {
        xhr.upload.onprogress = function (e) {
            var done = e.position || e.loaded, total = e.totalSize || e.total;
            var progress = Math.floor(done / total * 1000) / 10;
            if (typeof progressCallback === "function") {
                progressCallback(progress);
            }
        };
    }
    xhr.onreadystatechange = function (e) {
        if (4 == this.readyState) {
            if (typeof completeCallback === "function") {
                completeCallback(e);
            }
        }
    };

    var fd = new FormData;
    fd.append('file', file);
    xhr.open('post', url, true);
    xhr.send(fd);
}