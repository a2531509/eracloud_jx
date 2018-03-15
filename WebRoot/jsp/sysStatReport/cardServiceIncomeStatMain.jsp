<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>
<%@include file="/layout/initpage.jsp" %>
<!-- 卡服务收入报表 -->
<style>
 	.datagrid-header-row{
 		height:23px;
 	}
</style>
<script type="text/javascript">
	var $grid;
	var bknum = 0;
	var bk_sf_num = 0;
	var bk_wsf_num = 0;
	var bkcostfeeamt = 0.00;
	var bkurgamt = 0.00;
	var bkyjamt = 0.00;
	var bkcxnum = 0;
	var bkcx_sf_num = 0;
	var bkcx_wsf_num = 0;
	var bkcxcostfeeamt = 0.00;
	var bkcxurgamt = 0.00;
	var bkcxyjamt = 0.00;
	var hknum = 0;
	var hk_sf_num = 0;
	var hk_wsf_num = 0;
	var hkcostfeeamt = 0.00;
	var hkurgamt = 0.00;
	var hkyjamt = 0.00;
	var hkcxnum = 0;
	var hkcx_sf_num = 0;
	var hkcx_wsf_num = 0;
	var hkcxcostfeeamt = 0.00;
	var hkcxurgamt = 0.00;
	var hkcxyjamt = 0.00;
	var totnum = 0;
	var totamt = 0.00;
	$(function(){
		$("#synGroupIdTip").tooltip({
			position:"left",    
			content:"<span style='color:#B94A48'>是否级联下级网点</span>" 
		});
		$("#cascadeBrch").switchbutton({
			width:"50px",
			value:"0",
            checked:false,
            onText:"是",
            offText:"否"
		});
		
		createRegionSelect({id:"regionId"});
		
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
		if("${defaultErrMsg}" != ""){
			$.messager.alert("系统消息","${defaultErrMsg}","error");
		}
		createSysBranch(
			{id:"brchId"}
		);
		createSysCode({
			id:"cardType",
			codeType:"CARD_TYPE",
			codeValue:"<%=com.erp.util.Constants.CARD_TYPE_LIST %>",
			isShowDefaultOption:true
		});
		$grid = createDataGrid({
			id:"dg",
			url:"sysReportQuery/sysReportQueryAction!cardServiceIncomeStat.action",
			pagination:true,
			rownumbers:true,
			border:false,
			striped:true,
			fit:true,
			singleSelect:false,
			pageList : [100, 200, 500, 1000, 2000],
			scrollbarSize:0,
			autoRowHeight:true,
			view:myview,
			rowStyler:function(index, row){
				if(row.CARDTYPE == '本页信息统计'){
					return "font-weight:bold";
				}
			},
			frozenColumns:[
			    [
					{field:"V_V",rowspan:2,checkbox:true},
			     	{title:"网点信息",colspan:2,sortable:true},
			    	{field:"CARDTYPE",title:"卡类型",rowspan:2,sortable:true,width:parseInt($(this).width() * 0.08)},
			    	{title:"补卡",colspan:4,align:"center"}
			    ],
			    [
					{field:"BRCH_ID",title:"网点编号",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"FULL_NAME",title:"网点名称",align:"left",sortable:true},
					{field:"BKNUM",title:"笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"BK_SF_NUM",title:"收费笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"BK_WSF_NUM",title:"未收费笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"XJ1",title:"金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney((parseFloat(row.BKCOSTFEEAMT) + parseFloat(row.BKURGAMT) + parseFloat(row.BKYJAMT)).div100());
					}},
			    ]
			],
			columns:[
			    [
					{title:"补卡撤销",colspan:4,align:"center"},
					{title:"换卡",colspan:4,align:"center"},
					{title:"换卡撤销",colspan:4,align:"center"},
					{title:"合计",colspan:2,align:"center"}
			    ],
			    [
					{field:"BKCXNUM",title:"数量",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"BKCX_SF_NUM",title:"收费数量",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"BKCX_WSF_NUM",title:"未收费数量",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"XJ2",title:"金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney((parseFloat(row.BKCXCOSTFEEAMT) + parseFloat(row.BKCXURGAMT) + parseFloat(row.BKCXYJAMT)).div100());
					}},
					{field:"HKNUM",title:"笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"HK_SF_NUM",title:"收费笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"HK_WSF_NUM",title:"未收费笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"XJ3",title:"金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney((parseFloat(row.HKCOSTFEEAMT) + parseFloat(row.HKURGAMT) + parseFloat(row.HKYJAMT)).div100());
					}},
					{field:"HKCXNUM",title:"笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"HKCX_SF_NUM",title:"收费笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"HKCX_WSF_NUM",title:"未收费笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"XJ4",title:"金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney((parseFloat(row.HKCXCOSTFEEAMT) + parseFloat(row.HKCXURGAMT) + parseFloat(row.HKCXYJAMT)).div100());
					}},
					{field:"TOTNUM",title:"总笔数",align:"center",sortable:true,width:parseInt($(this).width() * 0.06)},
					{field:"TOTAMT",title:"总金额",align:"center",sortable:true,width:parseInt($(this).width() * 0.06),formatter:function(value,row,index){
						return $.foramtMoney(Number(value).div100());
					}}
			    ]
			],
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
            	for(var i=0,hk=rows.length;i < hk;i++){
            		var data  = rows[i];
            		calRow(true,data);
          	  	}
            	updateFooter();
            },
            onUncheckAll:function(rows){
            	initCal();
            	updateFooter();
            },
			onLoadSuccess:function(data){
				initGridFooter();
				$grid.datagrid("autoMergeCells",["FULL_NAME","BRCH_ID"]);
				if(dealNull(data["status"]) != 0){
					$.messager.alert("系统消息",data.errMsg,"warning");
				}
				updateFooter();
			}
		});
	});
	function initGridFooter(){
		$grid.datagrid("reloadFooter",[
  		    {"BKNUM":"0","BKCOSTFEEAMT":"0.00","BKURGAMT":"0.00","BKYJAMT":"0.00","BKCXNUM":"0","BKCXCOSTFEEAMT":"0.00","BKCXURGAMT":"0.00","BKCXYJAMT":"0.00",
  		    "HKNUM":"0","HKCOSTFEEAMT":"0.00","HKURGAMT":"0.00","HKYJAMT":"0.00","HKCXNUM":"0","HKCXCOSTFEEAMT":"0.00","HKCXURGAMT":"0.00","HKCXYJAMT":"0.00",
  		    "TOTNUM":"0","TOTAMT":"0.00","CARDTYPE":"本页信息统计"} 
  		]);
	}
	function initCal(){
		bknum = 0;
		bk_sf_num = 0;
		bk_wsf_num = 0;
    	bkcostfeeamt = 0.00;
    	bkurgamt = 0.00;
    	bkyjamt = 0.00;
    	bkcxnum = 0;
    	bkcx_sf_num = 0;
    	bkcx_wsf_num = 0;
    	bkcxcostfeeamt = 0.00;
    	bkcxurgamt = 0.00;
    	bkcxyjamt = 0.00;
    	hknum = 0;
    	hk_sf_num = 0;
    	hk_wsf_num = 0;
    	hkcostfeeamt = 0.00;
    	hkurgamt = 0.00;
    	hkyjamt = 0.00;
    	hkcxnum = 0;
    	hkcx_sf_num = 0;
    	hkcx_wsf_num = 0;
    	hkcxcostfeeamt = 0.00;
    	hkcxurgamt = 0.00;
    	hkcxyjamt = 0.00;
    	totnum = 0;
    	totamt = 0.00;
	}
	function calRow(is,data){
		if(is){
			bknum = parseFloat(bknum) + (isNaN(data.BKNUM)?0:parseFloat(data.BKNUM));
			bk_sf_num = parseFloat(bk_sf_num) + (isNaN(data.BK_SF_NUM)?0:parseFloat(data.BK_SF_NUM));
			bk_wsf_num = parseFloat(bk_wsf_num) + (isNaN(data.BK_WSF_NUM)?0:parseFloat(data.BK_WSF_NUM));
			bkcostfeeamt = parseFloat(bkcostfeeamt) + (isNaN(data.BKCOSTFEEAMT)?0:parseFloat(data.BKCOSTFEEAMT));
			bkurgamt = parseFloat(bkurgamt) + (isNaN(data.BKURGAMT)?0:parseFloat(data.BKURGAMT));
			bkyjamt = parseFloat(bkyjamt) + (isNaN(data.BKYJAMT)?0:parseFloat(data.BKYJAMT));
			bkcxnum = parseFloat(bkcxnum) + (isNaN(data.BKCXNUM)?0:parseFloat(data.BKCXNUM));
			bkcx_sf_num = parseFloat(bkcx_sf_num) + (isNaN(data.BKCX_SF_NUM)?0:parseFloat(data.BKCX_SF_NUM));
			bkcx_wsf_num = parseFloat(bkcx_wsf_num) + (isNaN(data.BKCX_WSF_NUM)?0:parseFloat(data.BKCX_WSF_NUM));
			bkcxcostfeeamt = parseFloat(bkcxcostfeeamt) + (isNaN(data.BKCXCOSTFEEAMT)?0:parseFloat(data.BKCXCOSTFEEAMT));
			bkcxurgamt = parseFloat(bkcxurgamt) + (isNaN(data.BKCXURGAMT)?0:parseFloat(data.BKCXURGAMT));
			bkcxyjamt = parseFloat(bkcxyjamt) + (isNaN(data.BKCXYJAMT)?0:parseFloat(data.BKCXYJAMT));
			hknum = parseFloat(hknum) + (isNaN(data.HKNUM)?0:parseFloat(data.HKNUM));
			hk_sf_num = parseFloat(hk_sf_num) + (isNaN(data.HK_SF_NUM)?0:parseFloat(data.HK_SF_NUM));
			hk_wsf_num = parseFloat(hk_wsf_num) + (isNaN(data.HK_WSF_NUM)?0:parseFloat(data.HK_WSF_NUM));
			hkcostfeeamt = parseFloat(hkcostfeeamt) + (isNaN(data.HKCOSTFEEAMT)?0:parseFloat(data.HKCOSTFEEAMT));
			hkurgamt = parseFloat(hkurgamt) + (isNaN(data.HKURGAMT)||!data.HKURGAMT?0:parseFloat(data.HKURGAMT));
			hkyjamt = parseFloat(hkyjamt) + (isNaN(data.HKYJAMT)?0:parseFloat(data.HKYJAMT));
			hkcxnum = parseFloat(hkcxnum) + (isNaN(data.HKCXNUM)?0:parseFloat(data.HKCXNUM));
			hkcx_sf_num = parseFloat(hkcx_sf_num) + (isNaN(data.HKCX_SF_NUM)?0:parseFloat(data.HKCX_SF_NUM));
			hkcx_wsf_num = parseFloat(hkcx_wsf_num) + (isNaN(data.HKCX_WSF_NUM)?0:parseFloat(data.HKCX_WSF_NUM));
			hkcxcostfeeamt = parseFloat(hkcxcostfeeamt) + (isNaN(data.HKCXCOSTFEEAMT)?0:parseFloat(data.HKCXCOSTFEEAMT));
			hkcxurgamt = parseFloat(hkcxurgamt) + (isNaN(data.HKCXURGAMT)?0:parseFloat(data.HKCXURGAMT));
			hkcxyjamt = parseFloat(hkcxyjamt) + (isNaN(data.HKCXYJAMT)?0:parseFloat(data.HKCXYJAMT));
			totnum = parseFloat(totnum) + (isNaN(data.TOTNUM)?0:parseFloat(data.TOTNUM));
			totamt = parseFloat(totamt) + (isNaN(data.TOTAMT)?0:parseFloat(data.TOTAMT));
		}else{
			bknum = parseFloat(bknum) - (isNaN(data.BKNUM)?0:parseFloat(data.BKNUM));
			bk_sf_num = parseFloat(bk_sf_num) - (isNaN(data.BK_SF_NUM)?0:parseFloat(data.BK_SF_NUM));
			bk_wsf_num = parseFloat(bk_wsf_num) - (isNaN(data.BK_WSF_NUM)?0:parseFloat(data.BK_WSF_NUM));
			bkcostfeeamt = parseFloat(bkcostfeeamt) - (isNaN(data.BKCOSTFEEAMT)?0:parseFloat(data.BKCOSTFEEAMT));
			bkurgamt = parseFloat(bkurgamt) - (isNaN(data.BKURGAMT)?0:parseFloat(data.BKURGAMT));
			bkyjamt = parseFloat(bkyjamt) - (isNaN(data.BKYJAMT)?0:parseFloat(data.BKYJAMT));
			bkcxnum = parseFloat(bkcxnum) - (isNaN(data.BKCXNUM)?0:parseFloat(data.BKCXNUM));
			bkcx_sf_num = parseFloat(bkcx_sf_num) - (isNaN(data.BKCX_SF_NUM)?0:parseFloat(data.BKCX_SF_NUM));
			bkcx_wsf_num = parseFloat(bkcx_wsf_num) - (isNaN(data.BKCX_WSF_NUM)?0:parseFloat(data.BKCX_WSF_NUM));
			bkcxcostfeeamt = parseFloat(bkcxcostfeeamt) - (isNaN(data.BKCXCOSTFEEAMT)?0:parseFloat(data.BKCXCOSTFEEAMT));
			bkcxurgamt = parseFloat(bkcxurgamt) - (isNaN(data.BKCXURGAMT)?0:parseFloat(data.BKCXURGAMT));
			bkcxyjamt = parseFloat(bkcxyjamt) - (isNaN(data.BKCXYJAMT)?0:parseFloat(data.BKCXYJAMT));
			hknum = parseFloat(hknum) - (isNaN(data.HKNUM)?0:parseFloat(data.HKNUM));
			hk_sf_num = parseFloat(hk_sf_num) - (isNaN(data.HK_SF_NUM)?0:parseFloat(data.HK_SF_NUM));
			hk_wsf_num = parseFloat(hk_wsf_num) - (isNaN(data.HK_WSF_NUM)?0:parseFloat(data.HK_WSF_NUM));
			hkcostfeeamt = parseFloat(hkcostfeeamt) - (isNaN(data.HKCOSTFEEAMT)?0:parseFloat(data.HKCOSTFEEAMT));
			hkurgamt = parseFloat(hkurgamt) - (isNaN(data.HKURGAMT)?0:parseFloat(data.HKURGAMT));
			hkyjamt = parseFloat(hkyjamt) - (isNaN(data.HKYJAMT)?0:parseFloat(data.HKYJAMT));
			hkcxnum = parseFloat(hkcxnum) - (isNaN(data.HKCXNUM)?0:parseFloat(data.HKCXNUM));
			hkcx_sf_num = parseFloat(hkcx_sf_num) - (isNaN(data.HKCX_SF_NUM)?0:parseFloat(data.HKCX_SF_NUM));
			hkcx_wsf_num = parseFloat(hkcx_wsf_num) - (isNaN(data.HKCX_WSF_NUM)?0:parseFloat(data.HKCX_WSF_NUM));
			hkcxcostfeeamt = parseFloat(hkcxcostfeeamt) - (isNaN(data.HKCXCOSTFEEAMT)?0:parseFloat(data.HKCXCOSTFEEAMT));
			hkcxurgamt = parseFloat(hkcxurgamt) - (isNaN(data.HKCXURGAMT)?0:parseFloat(data.HKCXURGAMT));
			hkcxyjamt = parseFloat(hkcxyjamt) - (isNaN(data.HKCXYJAMT)?0:parseFloat(data.HKCXYJAMT));
			totnum = parseFloat(totnum) - (isNaN(data.TOTNUM)?0:parseFloat(data.TOTNUM));
			totamt = parseFloat(totamt) - (isNaN(data.TOTAMT)?0:parseFloat(data.TOTAMT));
		}
	}
	function updateFooter(){
		$grid.datagrid('reloadFooter',[
   	        {	
   	        	CARDTYPE:"本页信息统计",
   	        	BKNUM:bknum,
   	        	BK_SF_NUM:bk_sf_num,
   	        	BK_WSF_NUM:bk_wsf_num,
   	        	BKCOSTFEEAMT:parseFloat(bkcostfeeamt).toFixed(2),
   	        	BKURGAMT:parseFloat(bkurgamt).toFixed(2),
   	        	BKYJAMT:parseFloat(bkyjamt).toFixed(2),
   	        	BKCXNUM:bkcxnum,
   	        	BKCX_SF_NUM:bkcx_sf_num,
   	        	BKCX_WSF_NUM:bkcx_wsf_num,
   	        	BKCXCOSTFEEAMT:parseFloat(bkcxcostfeeamt).toFixed(2),
   	        	BKCXURGAMT:parseFloat(bkcxurgamt).toFixed(2),
   	        	BKCXYJAMT:parseFloat(bkcxyjamt).toFixed(2),
   	        	HKNUM:hknum,
   	        	HK_SF_NUM:hk_sf_num,
   	        	HK_WSF_NUM:hk_wsf_num,
   	        	HKCOSTFEEAMT:parseFloat(hkcostfeeamt).toFixed(2),
   	        	HKURGAMT:parseFloat(hkurgamt).toFixed(2),
   	        	HKYJAMT:parseFloat(hkyjamt).toFixed(2),
   	        	HKCXNUM:hkcxnum,
   	        	HKCX_SF_NUM:hkcx_sf_num,
   	        	HKCX_WSF_NUM:hkcx_wsf_num,
   	        	HKCXCOSTFEEAMT:parseFloat(hkcxcostfeeamt).toFixed(2),
   	        	HKCXURGAMT:parseFloat(hkcxurgamt).toFixed(2),
   	        	HKCXYJAMT:parseFloat(hkcxyjamt).toFixed(2),
   	        	TOTNUM:totnum,
   	        	TOTAMT:parseFloat(totamt).toFixed(2)
   	        }
   	    ]);
	}
	var isExt;
	function startCycle(){
		isExt = setInterval("startDetect()",800);
	}
	function startDetect(){
		commonDwr.isDownloadComplete("cardServiceIncomeExportDownloadSuc",function(data){
			if(data["returnValue"] == '0'){
				clearInterval(isExt);
				jAlert("导出成功！","info",function(){
					$.messager.progress("close");
				});
			}
		});
	}
	function exportFile(){
		if(dealNull($("#startDate").val()) == ""){
			jAlert("请输入导出起始日期！",function(){
				$("#startDate").focus();
			});
			return;
		}
		if(dealNull($("#endDate").val()) == ""){
			jAlert("请输入导出结束日期！",function(){
				$("#endDate").focus();
			});
			return;
		}
		if($("#startDate").val() > $("#endDate").val()){
			jAlert("起始日期不能大于结束日期！");
			return;
		}
		jConfirm("您确定要进行导出吗？",function(){
			$.messager.progress({text:"正在进行导出,请稍候..."});
			var params = getformdata("searchConts");
			params["queryType"] = "0";
			params["rows"] = "1000";
			params["cascadeBrch"] = $("#cascadeBrch").prop("checked");
			var url = "";
			for(var i in params){
				url += "&" + i + "=" + params[i];
			}
			$("body").append("<iframe id=\"downloadcsv\" style=\"display:none\"></iframe>");
			$("#downloadcsv").attr("src","sysReportQuery/sysReportQueryAction!cardServiceIncomeExport.action?" + url.substr(1));
			startCycle();
		});
	}
	function query(){
		if(dealNull($("#startDate").val()) == ""){
			jAlert("请输入查询起始日期！",function(){
				$("#startDate").focus();
			});
			return;
		}
		if(dealNull($("#endDate").val()) == ""){
			jAlert("请输入查询结束日期！",function(){
				$("#endDate").focus();
			});
			return;
		}
		if($("#startDate").val() > $("#endDate").val()){
			jAlert("起始日期不能大于结束日期！");
			return;
		}
		var params = getformdata("searchConts");
		params["queryType"] = "0";
		params["cascadeBrch"] = $("#cascadeBrch").prop("checked");
		$grid.datagrid("load",params);
	}
</script>
<n:initpage title="卡服务中收取的工本费、押金、加急费进行统计操作！">
	<n:center>
		<div id="tb">
			<form id="searchConts">
				<table class="tablegrid">
					<tr>
						<!-- <td class="tableleft">所属机构：</td>
						<td class="tableright"><input id="orgId" name="rec.orgId" type="text" class="textinput"/></td> -->
						<td class="tableleft">所属网点：</td>
						<td class="tableright">
							<input id="brchId" name="rec.brchId" type="text" class="textinput"/>
							<span id="synGroupIdTip">
								<input id="cascadeBrch" name="cascadeBrch" type="checkbox">
							</span>
						</td>
						<td class="tableleft">所属区域：</td>
						<td class="tableright"><input id="regionId" name="region_Id" type="text" class="textinput"/></td>
						<!-- <td class="tableleft">所属柜员：</td>
						<td class="tableright"><input id="userId" name="rec.userId" type="text" class="textinput"/></td> -->
						<td class="tableleft">卡类型：</td>
						<td class="tableright"><input id="cardType" name="rec.cardType" type="text" class="textinput"/></td>
					</tr>
					<tr>
						<td class="tableleft">起始日期：</td>
						<td class="tableright"><input id="startDate" name="startDate" type="text" class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableleft">结束日期：</td>
						<td class="tableright"><input id="endDate" name="endDate" type="text"  class="Wdate textinput" readonly="readonly" onclick="WdatePicker({dateFmt:'yyyy-MM-dd',maxDate:'%y-%M-%d'})"/></td>
						<td class="tableright" colspan="2" style="padding-left: 20px">
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-search'" href="javascript:void(0);" class="easyui-linkbutton" onclick="query()">查询</a>
							<a style="text-align:center;margin:0 auto;" data-options="plain:false,iconCls:'icon-excel'" href="javascript:void(0);" class="easyui-linkbutton" onclick="exportFile()">导出</a>
						</td>
					</tr>
				</table>
			</form>
		</div>
  		<table id="dg" title="汇总信息" style="width:100%"></table>
	</n:center>
</n:initpage>
