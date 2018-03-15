<%@page language="java" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp"%>
<script type="text/javascript">
	$(function(){
		$.autoComplete({
			id:"merchantId",
			text:"merchant_id",
			value:"merchant_name",
			table:"base_merchant",
			keyColumn:"merchant_id",
			minLength:"1"
		},"merchantName");
		
		$.autoComplete({
			id:"merchantName",
			text:"merchant_name",
			value:"merchant_id",
			table:"base_merchant",
			keyColumn:"merchant_name",
			minLength:"1"
		},"merchantId");
		
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
			url:"sysReportQuery/sysReportQueryAction!merchantSettleQuery.action",
			toolbar:$("#tb"),
			fit:true,
			pagination:true,
			striped:true,
			border:false,
			pageList:[100, 500, 1000, 2000, 5000],
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
				{field:"", rowspan:3, checkbox:true},
				{field:"MERCHANT_ID", rowspan:3, title:"商户编号", width : 200, align:"center", sortable:true},
				{field:"MERCHANT_NAME", rowspan:3, title:"商户名称", width : 300, align:"center", sortable:true},
				{title:"已结算", colspan:6, align:"center"},
				{title:"未结算", colspan:2, rowspan:2, align:"center"},
				{title:"总计", colspan:2, rowspan:2, align:"center"}
			],[
				{title:"已支付", colspan:2, align:"center"},
				{title:"未支付", colspan:2, align:"center"},
				{title:"总计", colspan:2, align:"center"}
			],[
				{field:"YZF_NUM", title:"笔数", width : parseInt($(this).width() * 0.1), align:"center", sortable:true},
				{field:"YZF", title:"金额", width : parseInt($(this).width() * 0.1), align:"center", sortable:true, formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"WZF_NUM", title:"笔数", width : parseInt($(this).width() * 0.1), align:"center", sortable:true},
				{field:"WZF", title:"金额", width : parseInt($(this).width() * 0.1), align:"center", sortable:true, formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"YJS_NUM", title:"笔数", width : parseInt($(this).width() * 0.1), align:"center", sortable:true},
				{field:"YJS", title:"金额", width : parseInt($(this).width() * 0.1), align:"center", sortable:true, formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"WJS_NUM", title:"笔数", width : parseInt($(this).width() * 0.1), align:"center", sortable:true, formatter:function(v){
					if(isNaN(v)){
						v = 0;
					}
					return Number(v);
				}},
				{field:"WJS", title:"金额", width : parseInt($(this).width() * 0.1), align:"center", sortable:true, formatter:function(v){
					return $.foramtMoney(Number(v).div100());
				}},
				{field:"aa",title:"笔数", width : parseInt($(this).width() * 0.1), align:"center", sortable:true, formatter:function(v, r, i){
					var yjsNum = isNaN(r.YJS_NUM)?0:Number(r.YJS_NUM);
					var wjsNum = isNaN(r.WJS_NUM)?0:Number(r.WJS_NUM);
					return yjsNum + wjsNum;
				}},
				{field:"bb",title:"金额", width : parseInt($(this).width() * 0.1), align:"center", sortable:true, formatter:function(v, r, i){
					var yjsAmt = isNaN(r.YJS)?0:Number(r.YJS);
					var wjsAmt = isNaN(r.WJS)?0:Number(r.WJS);
					return $.foramtMoney(Number(yjsAmt + wjsAmt).div100());
				}}
			]],
			onLoadSuccess:function(data){
				if(dealNull(data["status"]) != 0){
					$.messager.alert("系统消息",data.errMsg,"warning");
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
			}
		});
	})
	
	function updateFooter(){
		var selections = $("#dg").datagrid("getSelections");
		
		var num = 0;
		var yjs = 0;
		var yjs_num = 0;
		var yzf = 0;
		var yzf_num = 0;
		var wzf = 0;
		var wzf_num = 0;
		var wjs = 0;
		var wjs_num = 0;
		var tot = 0;
		var tot_num = 0;
		
		for(var i in selections){
			var row = selections[i];
			num++;
			yjs += isNaN(row.YJS)?0:Number(row.YJS);
			yjs_num += isNaN(row.YJS_NUM)?0:Number(row.YJS_NUM);
			wjs += isNaN(row.WJS)?0:Number(row.WJS);
			wjs_num += isNaN(row.WJS_NUM)?0:Number(row.WJS_NUM);
			yzf += isNaN(row.YZF)?0:Number(row.YZF);
			yzf_num += isNaN(row.YZF_NUM)?0:Number(row.YZF_NUM);
			wzf += isNaN(row.WZF)?0:Number(row.WZF);
			wzf_num += isNaN(row.WZF_NUM)?0:Number(row.WZF_NUM);
			tot += isNaN(row.TOTAL)?0:Number(row.TOTAL);
			tot_num += isNaN(row.TOTAL_NUM)?0:Number(row.TOTAL_NUM);
		}
		
		$('#dg').datagrid("reloadFooter", [{isFooter:true, MERCHANT_ID:"统计：", MERCHANT_NAME:"共 " + num + " 条记录", YJS:yjs, YJS_NUM:yjs_num, WJS:wjs,WJS_NUM:wjs_num, YZF:yzf,YZF_NUM:yzf_num, WZF:wzf,WZF_NUM:wzf_num, TOTAL:tot,TOTAL_NUM:tot_num}])
	}
	
	function query(){
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		var merchantId = $("#merchantId").val();
		var merchantName = $("#merchantName").val();
		
		if(!startDate){
			jAlert("清分起始日期不能为空！", "warning");
			return;
		} else if(!endDate){
			jAlert("清分结束日期不能为空！", "warning");
			return;
		}
		
		var params = {
				query : true,
				startDate : startDate, 
				endDate : endDate, 
				merchantId : merchantId,
				merchantName : merchantName};
		
		$("#dg").datagrid("load", params);
	}
	
	function exportExcel(){
		var selections = $("#dg").datagrid("getSelections");
		if(!selections || selections.length == 0){
			jAlert("请选择需要导出的记录", "warning");
			return;
		}
		
		var merchantIds = "";
		for(var i in selections){
			merchantIds += "'" + selections[i].MERCHANT_ID + "',";
		}
		
		var startDate = $("#startDate").val();
		var endDate = $("#endDate").val();
		
		$("#download-frame").attr("src", "sysReportQuery/sysReportQueryAction!exportMerchantSettleInfo.action?startDate=" 
				+ startDate + "&endDate=" + endDate + "&merchantIds=" + merchantIds.substring(0, merchantIds.length - 1));
	}
</script>
<n:initpage>
	<n:north title="查询商户结算情况" />
	<n:center>
		<div id="tb" class="datagrid-toolbar">
			<table class="tablegrid">
				<tr>
					<td class="tableleft">商户编号:</td>
					<td class="tableright"><input id="merchantId" class="textinput"></td>
					<td class="tableleft">商户名称:</td>
					<td class="tableright"><input id="merchantName" class="textinput"></td>
					<td class="tableleft">结算起始时间:</td>
					<td class="tableright"><input id="startDate" class="textinput Wdate" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"></td>
					<td class="tableleft">结算结束时间:</td>
					<td class="tableright">
						<input id="endDate" class="textinput Wdate" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d', minDate:'#F{$dp.$D(\'startDate\')}'})">
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-search" plain="false" onclick="query()">查询</a>
						<a href="javascript:void(0);" class="easyui-linkbutton" iconCls="icon-excel" plain="false" onclick="exportExcel()">导出</a>
					</td>
				</tr>
			</table>
		</div>
		<table id="dg" title="商户结算情况" style="width: 100%"></table>
		<iframe id="download-frame" style="display: none">
		</iframe>
	</n:center>
</n:initpage>