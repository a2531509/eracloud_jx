<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript">
	var $merchantSettlementDataGrid;
	$(function(){
		createSysCode({id:"cardType",codeType:"CARD_TYPE"});
		
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
		
		$merchantSettlementDataGrid = $("#merchantSettlementDataGrid").datagrid({
			toolbar:"#tb",
			url:"merchantSettlement/merchantSettlementAction!queryMerchantSettlement.action",
			singleSelect:false,
			pageList:[100, 200, 500, 1000, 2000],
			pageSize:100,
			fit:true,
			pagination:true,
			striped:true,
			border:false,
			fitColumns:true,
			rownumbers:true,
			showFooter:true,
			onBeforeLoad:function(param){
				if(typeof(param["queryType"])=="undefined" || param["queryType"]!=0){
					return false;
				}
			},
			view:myview,
			rowStyler:function(index, row){
				if(row.isFooter){
					return "font-weight:bold";
				}
			},
			frozenColumns:[[
				{field:"MERCHANT_ID",title:"商家编号",checkbox:true,rowspan:2,align:"center",sortable:true,width:parseInt($(this).width()*0.10)},
				{field:"MERCHANT_NAME",title:"商家名称",rowspan:2,align:"center",sortable:true,width:parseInt($(this).width()*0.10)},
				{field:"CARD_NAME",title:"卡类型",rowspan:2,align:"center",sortable:true,width:parseInt($(this).width()*0.10)}
			],[]],
			columns:[[
				{title:"联机账户",colspan:4,align:"center"},
				{title:"电子钱包",colspan:4,align:"center"},
				{title:"退货",colspan:4,align:"center"},
				{field:"STL_AMT",title:"合计",rowspan:2,align:"center",sortable:true,width:parseInt($(this).width()*0.10),
					formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}
				}
			],[
				{field:"OL_DEAL_NUM",title:"交易笔数",align:"center",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"OL_DEAL_AMT",title:"交易金额",align:"center",sortable:true,width:parseInt($(this).width()*0.08),
					formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}
				},
				{field:"OL_STL_AMT",title:"结算金额",align:"center",sortable:true,width:parseInt($(this).width()*0.08),
					formatter:function(value,row,index){
						return $.foramtMoney(Number(row.OL_DEAL_AMT - row.OL_FEE_AMT).div100());
					}
				},
				{field:"OL_FEE_AMT",title:"手续费",align:"center",sortable:true,width:parseInt($(this).width()*0.08),
					formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}
				},
				{field:"OFL_DEAL_NUM",title:"交易笔数",align:"center",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"OFL_DEAL_AMT",title:"交易金额",align:"center",sortable:true,width:parseInt($(this).width()*0.08),
					formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}
				},
				{field:"OFL_STL_AMT",title:"结算金额",align:"center",sortable:true,width:parseInt($(this).width()*0.08),
					formatter:function(value,row,index){
						return $.foramtMoney(Number(row.OFL_DEAL_AMT - row.OFL_FEE_AMT).div100());
					}
				},
				{field:"OFL_FEE_AMT",title:"手续费",align:"center",sortable:true,width:parseInt($(this).width()*0.08),
					formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}
				},
				{field:"TH_NUM",title:"交易笔数",align:"center",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"TH_AMT",title:"交易金额",align:"center",sortable:true,width:parseInt($(this).width()*0.08),
					formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}
				},
				{field:"TH_STL_AMT",title:"结算金额",align:"center",sortable:true,width:parseInt($(this).width()*0.08),
					formatter:function(value,row,index){
						return $.foramtMoney(Number(row.TH_AMT - row.TH_FEE_AMT).div100());
					}
				},
				{field:"TH_FEE_AMT",title:"手续费",align:"center",sortable:true,width:parseInt($(this).width()*0.08),
					formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}
				}
			]],
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
			onLoadSuccess:function(){
				$merchantSettlementDataGrid.datagrid("autoMergeCells",["MERCHANT_ID","MERCHANT_NAME"]);
				updateFooter();
			}
		});
	});
	
	function updateFooter(){
		var selections = $("#merchantSettlementDataGrid").datagrid("getSelections");
		// on line
		var onLineDealNum = 0;
		var onLineDealAmt = 0;
		var onLineStlAmt = 0;
		var onLineFeeAmt = 0;
		// off line
		var offLineDealNum = 0;
		var offLineDealAmt = 0;
		var offLineStlAmt = 0;
		var offLineFeeAmt = 0;
		// tui huo
		var thDealNum = 0;
		var thDealAmt = 0;
		var thStlAmt = 0;
		var thFeeAmt = 0;
		// sum
		var sumAmt = 0;
		
		if(selections && selections.length > 0){
			for(var i in selections){
				var row = selections[i];
				// on line
				onLineDealNum += Number(row.OL_DEAL_NUM);
				onLineDealAmt += Number(row.OL_DEAL_AMT);
				onLineStlAmt += Number(row.OL_STL_AMT);
				onLineFeeAmt += Number(row.OL_FEE_AMT);
				// off line
				offLineDealNum += Number(row.OFL_DEAL_NUM);
				offLineDealAmt += Number(row.OFL_DEAL_AMT);
				offLineStlAmt += Number(row.OFL_STL_AMT);
				offLineFeeAmt += Number(row.OFL_FEE_AMT);
				// tui huo
				thDealNum += Number(row.TH_NUM);
				thDealAmt += Number(row.TH_AMT);
				thStlAmt += Number(row.TH_STL_AMT);
				thFeeAmt += Number(row.TH_FEE_AMT);
				// total
				sumAmt += Number(row.STL_AMT);
			}
		}
		
		var footer = {
			isFooter : true,
			MERCHANT_NAME : "统计信息：",
			OL_DEAL_NUM : onLineDealNum,
			OL_DEAL_AMT : onLineDealAmt,
			OL_STL_AMT : onLineStlAmt,
			OL_FEE_AMT : onLineFeeAmt,
			// off line
			OFL_DEAL_NUM : offLineDealNum,
			OFL_DEAL_AMT : offLineDealAmt,
			OFL_STL_AMT : offLineStlAmt,
			OFL_FEE_AMT : offLineFeeAmt,
			// tui huo
			TH_NUM : thDealNum,
			TH_AMT : thDealAmt,
			TH_STL_AMT : thStlAmt,
			TH_FEE_AMT : thFeeAmt,
			// sum
			STL_AMT : sumAmt
		}
		
		$("#merchantSettlementDataGrid").datagrid("reloadFooter", [ footer ]);
	}

	function query(){
		if(dealNull($("#beginDate").val())==""){
			$.messager.alert("系统消息","请选择起始日期！","error");
			return;
		}
		if(dealNull($("#endDate").val())==""){
			$.messager.alert("系统消息","请选择结束日期！","error");
			return;
		}
		var begin=new Date($("#beginDate").val().replace(/-/g,"/"));
		var end=new Date($("#endDate").val().replace(/-/g,"/"));
		if(begin-end>0){
			$.messager.alert("系统消息","起始日期不能大于结束日期！","error");
			return;
		}
		$merchantSettlementDataGrid.datagrid("load",{
			"queryType":"0",
			"merchantId":$("#merchantId").val(),
			"merchantName":$("#merchantName").val(),
			"cardType":$("#cardType").combobox("getValue"),
			"beginDate":$("#beginDate").val(),
			"endDate":$("#endDate").val()
		});
	}

	function createReport(){
		var rows=$merchantSettlementDataGrid.datagrid("getChecked");
		if(rows.length>0){
			var merchantIds="";
			for(var index=0;index<rows.length;index++){
				if(merchantIds!=""){
					merchantIds+=",";
				}
				merchantIds+="'"+rows[index].MERCHANT_ID+"'";
			}
			$.messager.progress({text:"数据处理中，请稍后...."});
			$.post("merchantSettlement/merchantSettlementAction!createReport.action",{
				"merchantIds":merchantIds,
				"cardType":$("#cardType").combobox("getValue"),
				"beginDate":$("#beginDate").val(),
				"endDate":$("#endDate").val()
			},function(data){
				data = eval("("+data+")");
				$.messager.progress("close");
				if(data.status=="0"){
					showReport(data.title,data.dealNo);
				}else{
					$.messager.alert("系统消息","操作失败！"+data.errMsg,"error");
				}
			})
		}else{
			$.messager.alert("系统消息","请选择要生成的商户结算记录","error");
		}
	}

	function exportExcel(){
		var rows=$merchantSettlementDataGrid.datagrid("getChecked");
		if(rows.length>0){
			var merchantIds="";
			for(var index=0;index<rows.length;index++){
				if(merchantIds!=""){
					merchantIds+=",";
				}
				merchantIds+="'"+rows[index].MERCHANT_ID+"'";
			}
			$.messager.confirm("系统消息","您确定要导出商户结算报表？",function(e){
				if(e){
					var beginDate=$("#beginDate").val();
					var endDate=$("#endDate").val();
					var cardType=$("#cardType").combobox("getValue");
					$("body").append("<iframe id=\"downloadexcel\" style=\"display:none\"></iframe>");
					$("#downloadexcel").attr("src","merchantSettlement/merchantSettlementAction!exportExcel.action?merchantIds="+merchantIds+
							"&beginDate="+beginDate+"&endDate="+endDate+"&cardType="+cardType);
				}
			});
		}else{
			$.messager.alert("系统消息","请选择要导出的商户结算记录","error");
		}
	}

	function autoCompleteById(){
		if($("#merchantId").val()==""){
			$("#merchantName").val("");
		}
		$("#merchantId").autocomplete({
			position:{my:"left top",at:"left bottom",of:"#merchantId"},
			source:function(request,response){
				$.post("merchantRegister/merchantRegisterAction!initAutoComplete.action",{"merchant.merchantId":$("#merchantId").val(),"queryType":"1"},function(data){
					response($.map(data.rows,function(item){return {label:item.label,value:item.text}}));
				},"json");
			},
			select:function(event,ui){
				$("#merchantId").val(ui.item.label);
				$("#merchantName").val(ui.item.value);
				return false;
			},
			focus:function(event,ui){
				return false;
			}
		});
	}

	function autoCompleteByName(){
		if($("#merchantName").val()==""){
			$("#merchantId").val("");
		}
		$("#merchantName").autocomplete({
			source:function(request,response){
				$.post("merchantRegister/merchantRegisterAction!initAutoComplete.action",{"merchant.merchantName":$("#merchantName").val(),"queryType":"0"},function(data){
					response($.map(data.rows,function(item){return {label:item.text,value:item.label}}));
				},"json");
			},
			select:function(event,ui){
				$("#merchantId").val(ui.item.value);
				$("#merchantName").val(ui.item.label);
				return false;
			},
			focus:function(event,ui){
				return false;
			}
		});
	}
</script>
<n:initpage title="商户结算信息进行查询！">
	<n:center>
		<div id="tb" style="padding:2px 0">
			<table cellpadding="0" cellspacing="0" style="width:100%" class="tablegrid">
				<tr>
					<td class="tableleft" style="width:8%">商家编号：</td>
					<td class="tableright" style="width:25%"><input type="text" name="merchantId" id="merchantId" class="textinput" onkeydown="autoCompleteById();" onkeyup="autoCompleteById();"/></td>
					<td class="tableleft" style="width:8%">商家名称：</td>
					<td class="tableright" style="width:25%"><input type="text" name="merchantName" id="merchantName" class="textinput" onkeydown="autoCompleteByName();" onkeyup="autoCompleteByName();"/></td>
					<td class="tableleft" style="width:8%">卡类型：</td>
					<td class="tableright" style="width:25%"><input type="text" name="cardType" id="cardType" class="textinput"/></td>
				</tr>
				<tr>
					<td class="tableleft" style="width:8%">清分起始日期：</td>
					<td class="tableright" style="width:25%"><input type="text" name="beginDate" id="beginDate" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})"/></td>
					<td class="tableleft" style="width:8%">清分结束日期：</td>
					<td class="tableright" style="width:25%"><input type="text" name="endDate" id="endDate" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false})"/></td>
					<td class="tableright" style="width:33%" colspan="2">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="query();">查询</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-merSettleQuery" plain="false" onclick="createReport();">生成报表</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-excel" plain="false" onclick="exportExcel()">导出</a>
					</td>
				</tr>
			</table>
		</div>
		<table id="merchantSettlementDataGrid" title="商户结算信息">
		</table>
	</n:center>
</n:initpage>