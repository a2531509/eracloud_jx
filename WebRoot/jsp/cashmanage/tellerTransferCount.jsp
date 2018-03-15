<%@page language="java" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp"%>
<script type="text/javascript">
	var footer;

	$(function(){
		createSysBranch("brchId","userId");
		
		$("#operId").combobox({
			url:"recharge/rechargeAction!getBranchSupervisor.action",
			valueField:"operId",
			textField:"name",
			loadFilter:function(data){
				var d = [{operId:"", name:"请选择"}];
				
				if(data || data.rows){
					var rows = data.rows;
					for(var i in rows){
						if(rows[i].dutyId >= 1){
							d.push(rows[i]);
						}
					}
				}
				
				return d;
			}
		});
		
		var myview = $.extend({}, $.fn.datagrid.defaults.view, {
		    renderFooter: function(target, container, frozen){
		        var opts = $.data(target, 'datagrid').options;
		        var rows = $.data(target, 'datagrid').footer || [];
		        var fields = $(target).datagrid('getColumnFields', frozen);
		        var table = ['<table class="datagrid-ftable" cellspacing="0" cellpadding="0" border="0"><tbody>'];
		         
		        for(var i=0; i<rows.length; i++){
		            var styleValue = opts.rowStyler ? opts.rowStyler.call(target, i, rows[i]) : '';
		            var style = styleValue ? 'style="' + styleValue + '"' : '';
		            table.push('<tr class="datagrid-row" datagrid-row-index="' + i + '"' + style + '>');
		            table.push(this.renderRow.call(this, target, fields, frozen, i, rows[i]));
		            table.push('</tr>');
		        }
		         
		        table.push('</tbody></table>');
		        $(container).html(table.join(''));
		    }
		});
		
		$("#dg").datagrid({
				url:"cashManage/cashManageAction!getTellerTransferInfo.action",
				toolbar:$("#tb"),
				fit:true,
				pagination:true,
				striped:true,
				border:false,
				pageList:[20, 50, 100, 200, 500],
				fitColumns:true,
				rownumbers:true,
				showFooter:true,
				view:myview,
				rowStyler:function(index, row){
					if(row.isFooter){
						return "font-weight:bold";
					}
				},
				columns:[[
					{field:"", checkbox:true},
					{field:"TRANSFER_DATE", title:"调剂日期", width : parseInt($(this).width() * 0.1), align:"center", sortable:true},
					{field:"TRANSFER_TIME", title:"调剂时间", width : parseInt($(this).width() * 0.1), align:"center", sortable:true},
					{field:"USER_NAME", title:"柜员姓名", width : parseInt($(this).width() * 0.1), align:"center", sortable:true},
					{field:"OPER_NAME", title:"主管姓名", width : parseInt($(this).width() * 0.1), align:"center", sortable:true},
					{field:"RECHARGE_AMT", title:"充值金额", width : parseInt($(this).width() * 0.1), align:"center", sortable:true, formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:"BHK_AMT", title:"补换卡金额", width : parseInt($(this).width() * 0.1), align:"center", sortable:true, formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}},
					{field:"TOTAL_AMT", title:"总计", width : parseInt($(this).width() * 0.1), align:"center", sortable:true, formatter:function(v){
						return $.foramtMoney(Number(v).div100());
					}}
				]],
				onLoadSuccess:function(data){
					if(dealNull(data["status"]) != 0){
						$.messager.alert("系统消息",data.errMsg,"warning");
					}
					
					if(data.footer){
						footer = data.footer[0];
					} else {
						footer = undefined;
					}
					updateFooter();
				},
				onBeforeLoad:function(params){
					if(!params["query"]){
						return false;
					}
					return true;
				},
				onSelect:function(){
					updateFooter();
				},
				onUnselect:function(){
					updateFooter();
				},
				onSelectAll:function(){
					updateFooter();
				},
				onUnselectAll:function(){
					updateFooter();
				},
			});
		})
		
		function updateFooter(){
			var selections = $("#dg").datagrid("getSelections");
			
			var rechargeAmt = 0;
			var bhkAmt = 0;
			var totalAmt = 0;
			
			for(var i in selections){
				rechargeAmt += Number(selections[i].RECHARGE_AMT);
				bhkAmt += Number(selections[i].BHK_AMT);
				totalAmt += Number(selections[i].TOTAL_AMT);
			}
			
			var footer2 = [{isFooter:true, TRANSFER_DATE:"柜员调剂总计", colspan:3 , RECHARGE_AMT:rechargeAmt, BHK_AMT:bhkAmt, TOTAL_AMT:totalAmt}];
			if(footer){
				footer.TRANSFER_DATE = "主管（" + footer.OPER_NAME + "）";
				footer2.unshift(footer);
				footer2.push({isFooter:true, TRANSFER_DATE:"总计", colspan:3 , RECHARGE_AMT:rechargeAmt + Number(footer.RECHARGE_AMT), BHK_AMT:bhkAmt + Number(footer.BHK_AMT), TOTAL_AMT:totalAmt + Number(footer.TOTAL_AMT)});
			}
			$("#dg").datagrid("reloadFooter", footer2);
		}
		
		function query(){
			var branchId = $("#brchId").combotree("getValue");
			var userId = $("#userId").combobox("getValue");
			var operId = $("#operId").combobox("getValue");
			var startDate = $("#startDate").val();
			var endDate = $("#endDate").val();
			
			var params = {
					query : true,
					startDate : startDate, 
					endDate : endDate, 
					branchId : branchId,
					userId : userId,
					operId : operId};
			
			$("#dg").datagrid("load", params);
		}

		function printReport(){
			var branchId = $("#brchId").combotree("getValue");
			var startDate = $("#startDate").val();
			var endDate = $("#endDate").val();
			
			var selections = $("#dg").datagrid("getSelections");
			if(!selections){
				jAlert("请选择调剂记录", "warning");
				return;
			}
			
			var serNos = "";
			for(var i in selections){
				serNos += "'" + selections[i].CASH_SER_NO + "',";
			}
			
			var params = {
					query : true,
					startDate : startDate, 
					endDate : endDate, 
					branchId : branchId,
					serNos : serNos.substring(0, serNos.length - 1)};
			
			$.messager.progress({text:"数据处理中..."});
			$.post("cashManage/cashManageAction!printTellerTransferDetail.action", params, function(data){
				$.messager.progress("close");
				if(data.status != 0){
					jAlert("打印凭证失败, " + data.errMsg, "error");
					return;
				}
				
				showReport("柜员调剂信息", data.dealNo);
			}, "json");
		}
		
		function exportReport(){
			var branchId = $("#brchId").combotree("getValue");
			var startDate = $("#startDate").val();
			var endDate = $("#endDate").val();
			
			var selections = $("#dg").datagrid("getSelections");
			if(!selections){
				jAlert("请选择调剂记录", "warning");
				return;
			}
			
			var serNos = "";
			for(var i in selections){
				serNos += "'" + selections[i].CASH_SER_NO + "',";
			}
			
			var params = {
					query : true,
					startDate : startDate, 
					endDate : endDate, 
					branchId : branchId,
					serNos : serNos.substring(0, serNos.length - 1)};
			
			var url = 'cashManage/cashManageAction!exportTellerTransferDetail.action?queryType=0&rows=20000&serNos=' + serNos.substring(0, serNos.length - 1);
			url += "&startDate=" + startDate + "&endDate=" + endDate + "&branchId=" + branchId;
			$('#downloadcsv').attr('src',url);
		}
</script>
<n:initpage>
	<n:north title="查看柜员调剂信息，【柜员】的【总计列】表示该柜员实调剂的金额，【主管】的【总计列】表示主管个人的充值补换卡总计" />
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<table class="tablegrid">
				<tr>
					<td class="tableleft">网点:</td>
					<td class="tableright"><input id="brchId" class="textinput"></td>
					<td class="tableleft">柜员:</td>
					<td class="tableright"><input id="userId" class="textinput"></td>
					<td class="tableleft">主管:</td>
					<td class="tableright"><input id="operId" class="textinput"></td>
				</tr>
				<tr>
					<td class="tableleft">起始时间:</td>
					<td class="tableright"><input id="startDate" class="textinput Wdate" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"></td>
					<td class="tableleft">结束时间:</td>
					<td class="tableright">
						<input id="endDate" class="textinput Wdate" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d', minDate:'#F{$dp.$D(\'startDate\')}'})">
					</td>
					<td class="tableright" style="padding-left: 20px" colspan="2">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="query()">查询</a>
						<shiro:hasPermission name="tellerTransferPrint">
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-print" plain="false" onclick="printReport()">打印</a>
							<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-excel" plain="false" onclick="exportReport()">导出</a>
						</shiro:hasPermission>
					</td>
				</tr>
			</table>
		</div>
		<table id="dg" title="柜员调剂信息" style="width: 100%"></table>
		<iframe id="downloadcsv" style="display:none"></iframe>
	</n:center>
</n:initpage>