<%@page import="com.erp.util.Constants"%>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<script type="text/javascript"> 
	var $grid;
	var totalNum = 0;
	var totalAmt = 0.00;
	$(function() {
		$.createDealCode("dealCode");
		
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST%>"
		});
		createSysCode({
			id:"accKind",
			codeType:"ACC_KIND"
		});
		
		$.autoComplete({
			id:"bankId",
			value:"bank_name",
			text:"bank_id",
			table:"base_bank",
			where:"bank_state = '0' ",
			keyColumn:"bank_id",
			minLength:1
		},"bankName");
		
		$.autoComplete({
			id:"bankName",
			value:"bank_id",
			text:"bank_name",
			table:"base_bank",
			where:"bank_state = '0' ",
			keyColumn:"bank_name",
			minLength:1
		},"bankId");
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
		$grid = createDataGrid({
			id:"dg",
			url:"statistical/statisticalAnalysisAction!bankQcQtQfInfo.action",
			fit:true,
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			pageList:[100, 500, 1000, 2000, 5000],
			singleSelect:false,
			autoRowHeight:true,
			showFooter:true,
			view:myview,
			rowStyler:function(index, row){
				if(row.isFooter){
					return "font-weight:bold";
				}
			},
			frozenColumns:[[
				{field:"DEAL_NO1",title:"id",sortable:true,checkbox:"ture"},
				{field:"DEAL_NO",title:"流水号",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"DEAL_BATCH_NO",title:"批次号",sortable:true,width:parseInt($(this).width()*0.08)},
				{field:"DEAL_CODE",title:"业务名称",sortable:true},
				{field:"BANK_ID",title:"银行编号",sortable:true},
				{field:"BANK_NAME",title:"银行名称",sortable:true},
			]],
			columns:[[
				{field:"NAME",title:"客户姓名",sortable:true,width:parseInt($(this).width()*0.06)},
				{field:"CERT_NO",title:"证件号码",sortable:true,width:parseInt($(this).width()*0.12)},
				{field:"CARD_TYPE",title:"卡类型",sortable:true,width:parseInt($(this).width()*0.06), formatter:function(v){
					if(v == <%=Constants.CARD_TYPE_QGN%>){
						return "全功能卡";
					} else if(v == <%=Constants.CARD_TYPE_SMZK%>){
						return "金融市民卡";
					}
					return v;
				}},
				{field:"CARD_NO",title:"卡号",sortable:true,width:parseInt($(this).width()*0.13)},
				{field:"ACC_KIND",title:"账户类型",sortable:true, formatter:function(v){
					if(v == <%=Constants.ACC_KIND_QBZH%>){
						return "市民卡钱包";
					} else if(v == <%=Constants.ACC_KIND_ZJZH%>){
						return "市民卡账户";
					}
					return v;
				}},
				{field:"AMT",title:"交易金额",sortable:true,width:parseInt($(this).width()*0.1),formatter:function(value,row,index){
					return $.foramtMoney(Number(value).div100());
				}},
				{field:"ORDER_TIME",title:"交易时间",sortable:true,width:parseInt($(this).width()*0.12)},
				{field:"ACPT_ID",title:"受理点编号", hidden:true, sortable:true},
				{field:"USER_ID",title:"终端/柜员编号",sortable:true},
				{field:"USER_NAME",title:"终端/柜员名称",sortable:true},
				{field:"END_DEAL_NO",title:"终端交易流水",sortable:true,width:parseInt($(this).width()*0.1)},
				{field:"CLR_DATE",title:"清分日期",sortable:true},
				{field:"DEAL_STATE",title:"状态",sortable:true, formatter:function(v){
					if ("01" == v) {
						return "初始生成";
					} else if ("02" == v) {
						return "已取消";
					} else if ("03" == v) {
						return "待确认";
					} else if ("04" == v) {
						return "正常";
					} else if ("05" == v) {
						return "已对账";
					} else if ("06" == v) {
						return "已撤销";
					} else if ("07" == v) {
						return "未登项";
					} else if ("98" == v) {
						return "可疑账";
					} else if ("99" == v) {
						return "已删除";
					} else {
						return v;
					}
				}}
			]],
		  	onCheck:function(index,data){
		  		calRow(true,data);
            	updateFooter();
            },
            onUncheck:function(index,data){
            	calRow(false,data);
            	updateFooter();
            },
            onCheckAll:function(rows){
            	initCal();
            	var i = 0;
            	var maxL = rows.length;
            	for(;i < maxL;i++){
            		calRow(true,rows[i]);
            	}
            	updateFooter();
            },
            onUncheckAll:function(rows){
            	initCal();
            	updateFooter();
            },
            onLoadSuccess:function(data){
            	if(data.status != 0){
            		jAlert(data.errMsg,"warning");
            	}
            	initCal();
            	updateFooter();
            }
		});
	});
	function initCal(){
		totalNum = 0;
		totalAmt = 0.00;
	}
	function calRow(is,data){
		if(is){
			totalNum = parseFloat(totalNum) + parseFloat(1);
       	  	totalAmt = parseFloat(totalAmt) + parseFloat(data.AMT);
		}else{
			totalNum = parseFloat(totalNum) - parseFloat(1);
       	  	totalAmt = parseFloat(totalAmt) - parseFloat(data.AMT);
		}
	}
	function updateFooter(){
		$grid.datagrid("reloadFooter",[{
			isFooter:true,
        	DEAL_CODE:"本页信息统计：",
        	BANK_ID:"共 " + parseFloat(totalNum) + " 笔",
        	CARD_BAL :"金额",
        	AMT:parseFloat(totalAmt).toFixed(2)}
        ]);
	}
	function query(){
		initCal();
		var params = getformdata("searchConts");
		params["queryType"] = "0"
		$grid.datagrid("load",params);
	}
	function readCard(){
		$.messager.progress({text : "正在验证卡信息,请稍后..."});
		cardinfo = getcardinfo();
		$.messager.progress("close");
		if(dealNull(cardinfo["card_No"]).length == 0){
			$.messager.alert("系统消息","读卡出现错误，请重新放置好卡片，再次进行读取！","error");
			return;
		}
		$("#cardNo").val(cardinfo["card_No"]);
		query();
	}
	
	function exportDetail(){
		var selections = $grid.datagrid("getSelections");
		var dealNos = "";
		if(selections && selections.length > 0){
			for(var i in selections){
				dealNos += selections[i].DEAL_NO + ",";
			}
		}
		$('#downloadcsv').attr('src','statistical/statisticalAnalysisAction!exportBankQcQtQfInfo.action?rows=20000&dealNos=' + dealNos.substring(0, dealNos.length - 1) + '&' + $("#searchConts").serialize());
	}
</script>
<n:initpage title="银行圈存圈提圈付明细进行查询操作！">
	<n:center>
		<div id="tb">
			<form id="searchConts">
				<input type="hidden" name="acptType" value="2"/>
				<table class="tablegrid">
					<tr>
						<td class="tableleft">流水号：</td>
						<td class="tableright"><input id="dealNo" type="text"  class="textinput easyui-validatebox" name="dealNo"/></td>
						<td class="tableleft">终端交易流水：</td>
						<td class="tableright"><input id="endSerNo" name="endSerNo" type="text" class="textinput"/></td>
						<td class="tableleft">银行编号：</td>
						<td class="tableright"><input id="bankId" type="text" class="textinput" name="bankId"/></td>
						<td class="tableleft">银行名称：</td>
						<td class="tableright"><input id="bankName" type="text" class="textinput" name="bankName"/></td>
					</tr>
					<tr>
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" type="text" class="textinput" name="cardType"/></td>
						<td class="tableleft">账户类型：</td>
						<td class="tableright"><input id="accKind" type="text" class="textinput" name="accKind" value="02"/></td>
						<td class="tableleft">清分起始日期：</td>
						<td class="tableright"><input  id="beginTime" type="text" name="clrStartDate" class="Wdate textinput" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">清分结束日期：</td>
						<td class="tableright"><input id="endTime" type="text"  name="clrEndDate" class="Wdate textinput"  onclick="WdatePicker({dateFmt:'yyyy-MM-dd',qsEnabled:false,maxDate:'%y-%M-%d'})"/></td>
					</tr>
					<tr>
						<td class="tableleft">业务类型：</td>
						<td class="tableright"><input id="dealCode" type="text" class="textinput" name="dealCode"/></td>
						<td class="tableleft">卡号：</td>
						<td class="tableright" colspan="5">
							<input id="cardNo" type="text" class="textinput" name="cardNo"/>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-readCard'" href="javascript:void(0);" class="easyui-linkbutton" onclick="readCard()">读卡</a>
							&nbsp;&nbsp;<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportDetail()">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="银行圈存圈提圈付详细信息"></table>
  		<iframe id="downloadcsv" style="display:none"></iframe>
  	</n:center>
</n:initpage>